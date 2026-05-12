//
//  UserService.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import Foundation
import FirebaseFirestore

enum UserService {
    static func createUserDocument(
        uid: String,
        username: String,
        email: String
    ) async throws {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "id": uid,
            "username": username.lowercased(),
            "email": email,
            "bio": "",
            "profileImageUrl": NSNull(),
            "dateJoined": Timestamp(date: Date()),
            "followerCount": 0,
            "followingCount": 0,
            "postCount": 0
        ]
        
        try await db.collection("users").document(uid).setData(userData)
    }
    
    static func fetchUser(uid: String) async throws -> AppUser {
        let db = Firestore.firestore()
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else {
            throw URLError(.badServerResponse)
        }
        return AppUser(
            id: data["id"] as? String ?? uid,
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            bio: data["bio"] as? String ?? "",
            profileImageUrl: data["profileImageUrl"] as? String,
            dateJoined: (data["dateJoined"] as? Timestamp)?.dateValue() ?? Date(),
            followerCount: data["followerCount"] as? Int ?? 0,
            followingCount: data["followingCount"] as? Int ?? 0,
            postCount: data["postCount"] as? Int ?? 0
        )
    }
    
    static func updateProfile(
        uid: String,
        bio: String,
        profileImageUrl: String?
    ) async throws {
        let db = Firestore.firestore()
        var updates: [String: Any] = ["bio": bio]
        if let url = profileImageUrl {
            updates["profileImageUrl"] = url
        }
        
        try await db.collection("users").document(uid).updateData(updates)
    }
    
    static func searchUsers(query: String) async throws -> [AppUser] {
        guard !query.isEmpty else { return [] }
        let db = Firestore.firestore()
        let lowered = query.lowercased()
        let snapshot = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: lowered)
            .whereField("username", isLessThan: lowered + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            return AppUser(
                id: d["id"] as? String ?? doc.documentID,
                username: d["username"] as? String ?? "",
                email: d["email"] as? String ?? "",
                bio: d["bio"] as? String ?? "",
                profileImageUrl: d["profileImageUrl"] as? String,
                dateJoined: (d["dateJoined"] as? Timestamp)?.dateValue() ?? Date(),
                followerCount: d["followerCount"] as? Int ?? 0,
                followingCount: d["followingCount"] as? Int ?? 0,
                postCount: d["postCount"] as? Int ?? 0
            )
        }
    }
}
