//
//  FollowService.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import Foundation
import FirebaseFirestore

enum FollowService {
    static func follow(currentUid: String, targetUid: String) async throws {
        let db = Firestore.firestore()
        let batch = db.batch()
        let followingRef = db.collection("users").document(currentUid)
            .collection("following").document(targetUid)
        batch.setData(["timestamp": Timestamp()], forDocument: followingRef)
        let followerRef = db.collection("users").document(targetUid)
            .collection("followers").document(currentUid)
        batch.setData(["timestamp": Timestamp()], forDocument: followerRef)
        let currentUserRef = db.collection("users").document(currentUid)
        batch.updateData(["followingCount": FieldValue.increment(Int64(1))],
                         forDocument: currentUserRef)
        let targetUserRef = db.collection("users").document(targetUid)
        batch.updateData(["followerCount": FieldValue.increment(Int64(1))],
                         forDocument: targetUserRef)
        try await batch.commit()
    }
    
    static func unfollow(currentUid: String, targetUid: String) async throws {
        let db = Firestore.firestore()
        let batch = db.batch()
        let followingRef = db.collection("users").document(currentUid)
            .collection("following").document(targetUid)
        batch.deleteDocument(followingRef)
        let followerRef = db.collection("users").document(targetUid)
            .collection("followers").document(currentUid)
        batch.deleteDocument(followerRef)
        let currentUserRef = db.collection("users").document(currentUid)
        batch.updateData(["followingCount": FieldValue.increment(Int64(-1))],
            forDocument: currentUserRef)
        let targetUserRef = db.collection("users").document(targetUid)
        batch.updateData(["followerCount": FieldValue.increment(Int64(-1))],
            forDocument: targetUserRef)
        try await batch.commit()
    }
    
    static func isFollowing(currentUid: String, targetUid: String) async -> Bool {
        let db = Firestore.firestore()
        let doc = try? await db.collection("users").document(currentUid)
            .collection("following").document(targetUid).getDocument()
        return doc?.exists ?? false
    }
    
    static func getFollowerIds(uid: String) async throws -> [String] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(uid)
            .collection("followers").getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
    
    static func getFollowingIds(uid: String) async throws -> [String] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(uid)
            .collection("following").getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
}
