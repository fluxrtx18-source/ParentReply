import SwiftUI
import PhotosUI

/// The primary CTA on the HomeView.
/// Presents a PhotosPicker when tapped; calls back with the chosen image.
struct MainActionButton: View {
    let onImage: (UIImage) -> Void

    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 56)
        }
        .overlay {
            MainActionButtonLabel(isLoading: isLoading)
                .allowsHitTesting(false)
        }
        .task(id: pickerItem) {
            guard let item = pickerItem else { return }
            isLoading = true
            defer { isLoading = false; pickerItem = nil }
            do {
                guard let data  = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    loadError = "The photo couldn't be read. Try choosing a different image."
                    return
                }
                onImage(image)
            } catch {
                loadError = "Couldn't load the photo from your library. Please try again."
            }
        }
        .alert("Couldn't Load Photo", isPresented: .init(
            get: { loadError != nil },
            set: { if !$0 { loadError = nil } }
        ), presenting: loadError) { _ in
            Button("OK", role: .cancel) { loadError = nil }
        } message: { error in
            Text(error)
        }
    }
}
