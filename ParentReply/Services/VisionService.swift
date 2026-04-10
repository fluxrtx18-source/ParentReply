import Vision
import UIKit

protocol TextExtracting: Sendable {
    func extractText(from image: UIImage) async throws -> String
}

/// Extracts readable text from a UIImage using Apple's Vision framework (on-device OCR).
actor VisionService: TextExtracting {

    // Cap applied before .cgImage extraction so we never decompress a full
    // 48 MP ProRAW frame into memory (~192 MB as a raw CGImage bitmap).
    private static let maxOCRDimension: CGFloat = 2048

    func extractText(from image: UIImage) async throws -> String {
        let scaledImage = downscaled(image, toMaxDimension: Self.maxOCRDimension)
        guard let cgImage = scaledImage.cgImage else {
            throw VisionError.invalidImage
        }

        // Run synchronous Vision OCR in a detached task so the blocking
        // VNImageRequestHandler.perform() call does not occupy a cooperative
        // thread. Task.detached is appropriate here: cgImage is Sendable and
        // there is no shared mutable state inside the closure.
        let text = try await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.revision = VNRecognizeTextRequest.currentRevision
            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            return (request.results ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
        }.value

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw VisionError.noTextFound
        }
        return text
    }

    // MARK: - Private helpers

    private func downscaled(_ image: UIImage, toMaxDimension maxDimension: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }
        let scale = maxDimension / longest
        let targetSize = CGSize(
            width:  (image.size.width  * scale).rounded(),
            height: (image.size.height * scale).rounded()
        )
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: targetSize)) }
    }

    enum VisionError: LocalizedError {
        case invalidImage
        case noTextFound

        var errorDescription: String? {
            switch self {
            case .invalidImage:  "Could not read the image. Try again with a clear screenshot."
            case .noTextFound:   "No text was found in the screenshot. Make sure it contains a readable school message."
            }
        }
    }
}
