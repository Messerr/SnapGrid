//
//  PostService.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import Foundation
import FirebaseFirestore

enum PostService {
    static func createPost(
        userId: String,
        username: String,
        profileImageUrl: String?,
        imageData: Data,
        caption: String
    ) async throws {
        let db = Firestore.firestore()
        let postId = UUID().uuidString
        let imageUrl = try await StorageService.uploadPostImage(
            postId: postId,
            imageData: imageData
        )
        let postData: [String: Any] = [
            "id": postId,
            "userId": userId,
            "username": username,
            "userProfileImageUrl": profileImageUrl as Any,
            "imageUrl": imageUrl,
            "caption": caption,
            "likeCount": 0,
            "commentCount": 0,
            "datePosted": Timestamp(date: Date())
        ]
        try await db.collection("posts").document(postId).setData(postData)
        try await db.collection("users").document(userId).updateData([
            "postCount": FieldValue.increment(Int64(1))
        ])
    }
    
    static func fetchUserPosts(userId: String) async throws -> [Post] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("posts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "datePosted", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            return Post(
                id: d["id"] as? String ?? doc.documentID,
                userId: d["userId"] as? String ?? "",
                username: d["username"] as? String ?? "",
                userProfileImageUrl: d["userProfileImageUrl"] as? String,
                imageUrl: d["imageUrl"] as? String ?? "",
                caption: d["caption"] as? String ?? "",
                likeCount: d["likeCount"] as? Int ?? 0,
                commentCount: d["commentCount"] as? Int ?? 0,
                datePosted: (d["datePosted"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
    
    static func fetchFeedPosts() async throws -> [Post] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("posts")
            .order(by: "datePosted", descending: true)
            .limit(to: 50)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            return Post(
                id: d["id"] as? String ?? doc.documentID,
                userId: d["userId"] as? String ?? "",
                username: d["username"] as? String ?? "",
                userProfileImageUrl: d["userProfileImageUrl"] as? String,
                imageUrl: d["imageUrl"] as? String ?? "",
                caption: d["caption"] as? String ?? "",
                likeCount: d["likeCount"] as? Int ?? 0,
                commentCount: d["commentCount"] as? Int ?? 0,
                datePosted: (d["datePosted"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
    
    static func fetchFollowedUserIds(uid: String) async throws -> [String] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("useres").document(uid)
            .collection("following").getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
    
    static func fetchFollowedFeedPosts(userId: String) async throws -> [Post] {
        let db = Firestore.firestore()
        var followedIds = try await fetchFollowedUserIds(uid: userId)
        followedIds.append(userId)
        guard !followedIds.isEmpty else {
            return try await fetchFeedPosts()
        }
        let limitedIds = Array(followedIds.prefix(30))
        let snapshot = try await db.collection("posts")
            .whereField("userid", in: limitedIds)
            .order(by: "datePosted", descending: true)
            .limit(to: 50)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            return Post(
                id: d["id"] as? String ?? doc.documentID,
                userId: d["userId"] as? String ?? "",
                username: d["username"] as? String ?? "",
                userProfileImageUrl: d["userProfileImageUrl"] as? String,
                imageUrl: d["imageUrl"] as? String ?? "",
                caption: d["caption"] as? String ?? "",
                likeCount: d["likeCount"] as? Int ?? 0,
                commentCount: d["commentCount"] as? Int ?? 0,
                datePosted: (d["datePosted"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
}
