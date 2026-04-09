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

        // Run synchronous Vision OCR on a non-cooperative thread to avoid
        // starving the Swift concurrency thread pool with a blocking call.
        let text: String = try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let request = VNRecognizeTextRequest()
                    request.revision = VNRecognizeTextRequest.currentRevision
                    request.recognitionLevel = .accurate

                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])

                    let result = (request.results ?? [])
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: "\n")

                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        guard !text.isEmpty else { throw VisionError.noTextFound }
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
