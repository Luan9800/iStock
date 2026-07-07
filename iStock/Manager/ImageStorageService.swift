//
//  ImageStorageService.swift
//  iStock
//
//  Created by Berg Limma on 07/07/26.
//

import Foundation
import FirebaseStorage

@MainActor
final class ImageStorageService {
    static let shared = ImageStorageService()

    private let storage = Storage.storage().reference()

    private init() {}

    func upload(data: Data, path: String) async throws -> URL {
        let ref = storage.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        return try await ref.downloadURL()
    }

    func delete(path: String) async throws {
        try await storage.child(path).delete()
    }
}
