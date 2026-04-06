import SwiftUI

final class ProfilePhotoService {

    static let shared = ProfilePhotoService()

    private let fileName = "profile_photo.jpg"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func save(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: fileURL)
    }

    func load() -> UIImage? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    func delete() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
