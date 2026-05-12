//
//  StorageService.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import Foundation
import FirebaseStorage

enum StorageService {
    static func uploadProfileImage(uid: String, imageData: Data) async throws -> String {
        let ref = Storage.storage().reference()
            .child("profiles/\(uid)/avatar.jpg")
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            ref.putData(imageData, metadata: nil) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    static func uploadPostImage(postId: String, imageData: Data) async throws -> String {
        let ref = Storage.storage().reference()
            .child("posts/\(postId)/image.jpg")
        
        
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            ref.putData(imageData, metadata: nil) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
