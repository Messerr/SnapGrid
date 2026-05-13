//
//  CommentService.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import Foundation
import FirebaseFirestore

enum CommentService {
    static func fetchComments(postId: String) async throws -> [Comment] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("posts").document(postId)
            .collection("comments")
            .order(by: "timestamp")
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            return Comment(
                id: doc.documentID,
                userId: d["userId"] as? String ?? "",
                username: d["username"] as? String ?? "",
                text: d["text"] as? String ?? "",
                timestamp: (d["timestamp"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
    
    static func addComment(
        postId: String, userId: String,
        username: String, text: String
    ) async throws {
        let db = Firestore.firestore()
        let commentData: [String: Any] = [
            "userId": userId,
            "username": username,
            "text": text,
            "timestamp": Timestamp()
        ]
        try await db.collection("posts").document(postId)
            .collection("comments").addDocument(data: commentData)
        try await db.collection("posts").document(postId)
            .updateData(["commentCount": FieldValue.increment(Int64(1))])
    }
}
