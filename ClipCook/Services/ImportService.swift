import Foundation
import LinkPresentation
import UIKit

struct ImportMetadata {
    var title: String?
    var imageData: Data?
    var description: String?
}

enum ImportResult {
    case success(ImportMetadata)
    case failure(String)
}

final class ImportService {
    func importFromURL(_ url: URL) async -> ImportResult {
        let metadata: LPLinkMetadata
        do {
            let provider = LPMetadataProvider()
            provider.timeout = 7
            metadata = try await provider.startFetchingMetadata(for: url)
        } catch {
            return .failure(error.localizedDescription)
        }

        let title = metadata.title
        let imageData = await loadImageData(from: metadata.imageProvider)
        let description = metadata.value(forKey: "summary") as? String

        return .success(ImportMetadata(
            title: title,
            imageData: imageData,
            description: description
        ))
    }

    private func loadImageData(from provider: NSItemProvider?) async -> Data? {
        guard let provider else { return nil }

        return await withCheckedContinuation { continuation in
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        continuation.resume(returning: image.jpegData(compressionQuality: 0.8))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            } else {
                provider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, _ in
                    continuation.resume(returning: data)
                }
            }
        }
    }

    static func saveImageLocally(_ data: Data, id: String) -> String? {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = dir?.appendingPathComponent("recipe_\(id).jpg") else { return nil }
        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            return nil
        }
    }
}
