//
//  LikeService.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import Foundation
import FirebaseFirestore

enum LikeService {
    static func likePost(postId: String, userId: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("posts").document(postId)
            .collection("likes").document(userId)
            .setData(["timestamp": Timestamp()])
        try await db.collection("posts").document(postId)
            .updateData(["likeCount": FieldValue.increment(Int64(1))])
    }
    
    static func unlikePost(postId: String, userId: String) async throws {
        let db = Firestore.firestore()
        try await db.collection("posts").document(postId)
            .collection("likes").document(userId)
            .delete()
        try await db.collection("posts").document(postId)
            .updateData(["likeCount": FieldValue.increment(Int64(-1))])
    }
    
    static func hasLiked(postId: String, userId: String) async -> Bool {
        let db = Firestore.firestore()
        let doc = try? await db.collection("posts").document(postId)
            .collection("likes").document(userId)
            .getDocument()
        return doc?.exists ?? false
    }
}
