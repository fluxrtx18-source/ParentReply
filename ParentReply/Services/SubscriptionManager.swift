import StoreKit

/// Manages StoreKit 2 products, purchases, and entitlement verification.
@MainActor
@Observable
final class SubscriptionManager {

    // MARK: - Product IDs (must match App Store Connect)
    static let weeklyID  = "com.parentreply.weekly"
    static let monthlyID = "com.parentreply.monthly"
    static let yearlyID  = "com.parentreply.yearly"

    static let productIDs = [weeklyID, monthlyID, yearlyID]

    // MARK: - Observed state
    private(set) var products: [Product] = []
    private(set) var activeSubscription: Product?
    private(set) var subscribedProductIDs: Set<String> = []
    private(set) var isLoadingProducts = false
    private(set) var purchaseError: String?
    var restoreMessage: String?
    private(set) var isRestoring = false
    /// `true` when a purchase is awaiting external approval (SCA or Ask to Buy).
    private(set) var hasPendingTransaction = false
    /// `true` when the user's subscription is in billing retry (payment method issue).
    private(set) var hasBillingIssue = false

    var isSubscribed: Bool { !subscribedProductIDs.isEmpty }

    // MARK: - Private
    // `nonisolated(unsafe)` is required here because `deinit` has no actor context
    // and must be able to cancel the task. Only `init` writes this property (on the
    // main actor) and only `deinit` reads it (off-actor). No concurrent access occurs.
    @ObservationIgnored
    private nonisolated(unsafe) var transactionListenerTask: Task<Void, Never>?

    init() {
        transactionListenerTask = startTransactionListener()
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Public API

    func loadProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        purchaseError = nil
        defer { isLoadingProducts = false }

        do {
            let fetched = try await Product.products(for: Self.productIDs)
                .sorted { $0.price > $1.price }  // Annual first — best value anchor

            if fetched.isEmpty {
                #if DEBUG
                purchaseError = "No products returned. Run from Xcode with StoreKit config enabled."
                #else
                purchaseError = "Plans unavailable. Please try again later."
                #endif
            } else {
                products = fetched
                await refreshEntitlements()
            }
        } catch {
            #if DEBUG
            purchaseError = "Could not load plans: \(error.localizedDescription)"
            #else
            purchaseError = "Could not load plans. Please check your connection and try again."
            #endif
        }
    }

    func purchase(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await refreshEntitlements()
                    await transaction.finish()
                case .unverified(_, let verificationError):
                    // Do NOT finish — Apple will re-deliver the transaction.
                    // Finishing would permanently discard a potentially valid purchase.
                    #if DEBUG
                    print("[StoreKit] Unverified purchase: \(verificationError)")
                    #endif
                    purchaseError = "Purchase verification failed. Please try again."
                }
            case .pending:
                hasPendingTransaction = true
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch let error as StoreKitError {
            switch error {
            case .userCancelled:
                break
            case .networkError:
                purchaseError = "Check your internet connection and try again."
            case .notAvailableInStorefront:
                purchaseError = "This plan isn't available in your region."
            default:
                purchaseError = "Purchase couldn't be completed. Please try again."
            }
        } catch let error as Product.PurchaseError {
            switch error {
            case .purchaseNotAllowed:
                purchaseError = "Purchases are restricted on this device. Check Screen Time settings."
            case .ineligibleForOffer:
                purchaseError = "You're not eligible for this offer."
            default:
                purchaseError = "Purchase couldn't be completed. Please try again."
            }
        } catch {
            purchaseError = "Purchase couldn't be completed. Please try again."
        }
    }

    /// Refreshes subscription status without re-fetching product metadata.
    func refresh() async {
        await refreshEntitlements()
    }

    func restore() async {
        isRestoring = true
        purchaseError = nil
        restoreMessage = nil
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if activeSubscription == nil && !isSubscribed {
                restoreMessage = "No active subscription found for this Apple ID."
            }
        } catch StoreKitError.userCancelled {
            // User dismissed the Apple ID sign-in sheet — not a real error.
        } catch {
            #if DEBUG
            purchaseError = error.localizedDescription
            #else
            purchaseError = "Restore couldn't be completed. Please try again."
            #endif
        }
    }

    // MARK: - Private helpers

    private func refreshEntitlements() async {
        var validProductIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            // Only trust Apple-verified transactions.
            guard case .verified(let transaction) = result else { continue }
            // Auto-renewable subscriptions only; skip consumables and non-renewables.
            guard transaction.productType == .autoRenewable else { continue }
            // Skip revoked (refunded/Family-Sharing-removed) transactions.
            guard transaction.revocationDate == nil else { continue }
            // Skip superseded transactions when the user has upgraded to a higher tier.
            guard !transaction.isUpgraded else { continue }
            // Note: do NOT check expirationDate here. Transaction.currentEntitlements
            // already excludes expired subscriptions, and adding an explicit date check
            // would incorrectly cut off users who are in Apple's billing grace period
            // (where expirationDate is past but access is still granted).

            validProductIDs.insert(transaction.productID)
        }

        subscribedProductIDs = validProductIDs
        if !products.isEmpty {
            activeSubscription = products
                .filter { validProductIDs.contains($0.id) }
                .max(by: { $0.price < $1.price })
        }

        // Check for billing retry state so we can nudge the user to update
        // their payment method when their subscription payment has failed.
        var billingIssueDetected = false
        for id in Self.productIDs {
            guard let product = products.first(where: { $0.id == id }),
                  let statuses = try? await product.subscription?.status else { continue }
            for status in statuses {
                if status.state == .inBillingRetryPeriod || status.state == .inGracePeriod {
                    billingIssueDetected = true
                }
            }
        }
        hasBillingIssue = billingIssueDetected
    }

    /// Clears the pending-transaction flag and refreshes entitlements.
    /// Called by the transaction listener when a pending purchase is approved.
    private func clearPendingAndRefresh() async {
        hasPendingTransaction = false
        await refreshEntitlements()
    }

    private func startTransactionListener() -> Task<Void, Never> {
        // Detached so the long-running async-sequence loop does not
        // inherit @MainActor isolation from its call site. Any state
        // mutations are awaited back onto the main actor inside
        // refreshEntitlements() which is itself @MainActor.
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await self?.clearPendingAndRefresh()
                    await transaction.finish()
                case .unverified(_, let verificationError):
                    // Do NOT finish — Apple will re-deliver on next launch.
                    // Finishing permanently discards a potentially valid purchase.
                    #if DEBUG
                    print("[StoreKit] Unverified transaction: \(verificationError)")
                    #endif
                }
            }
        }
    }
}
