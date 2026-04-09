import UIKit

/// Lightweight wrapper to make UIImage compatible with SwiftUI's `.sheet(item:)`.
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
