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
    private(set) var isLoadingProducts = false
    private(set) var purchaseError: String?
    private(set) var isRestoring = false

    var isSubscribed: Bool { activeSubscription != nil }

    // MARK: - Private
    @ObservationIgnored
    private nonisolated(unsafe) var transactionListenerTask: Task<Void, Error>?

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
                .sorted { $0.price < $1.price }

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
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            #if DEBUG
            purchaseError = error.localizedDescription
            #else
            purchaseError = "Purchase couldn't be completed. Please try again."
            #endif
        }
    }

    /// Refreshes subscription status without re-fetching product metadata.
    func refresh() async {
        await refreshEntitlements()
    }

    func restore() async {
        isRestoring = true
        purchaseError = nil
        defer { isRestoring = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if activeSubscription == nil {
                purchaseError = "No active subscription found for this Apple ID."
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
            guard case .verified(let transaction) = result,
                  transaction.productType == .autoRenewable,
                  transaction.revocationDate == nil else { continue }

            if let expirationDate = transaction.expirationDate,
               expirationDate < Date.now {
                continue
            }

            validProductIDs.insert(transaction.productID)
        }

        activeSubscription = products
            .filter { validProductIDs.contains($0.id) }
            .max(by: { $0.price < $1.price })
    }

    private func startTransactionListener() -> Task<Void, Error> {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw PurchaseError.verificationFailed
        case .verified(let value): return value
        }
    }

    enum PurchaseError: LocalizedError {
        case verificationFailed
        var errorDescription: String? { "Purchase verification failed. Please try again." }
    }
}
