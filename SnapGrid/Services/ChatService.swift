//
//  ChatService.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import Foundation
import FirebaseFirestore

enum ChatService {
    static func findOrCreateConversation(
        currentUid: String, otherUid: String
    ) async throws -> String {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .getDocuments()
        
        for doc in snapshot.documents {
            let participants = doc.data()["participants"] as? [String] ?? []
            if participants.contains(otherUid) {
                return doc.documentID
            }
        }
        
        let convData: [String: Any] = [
            "participants": [currentUid, otherUid],
            "lastMessage": "",
            "lastMessageDate": Timestamp()
        ]
        let ref = try await db.collection("conversations").addDocument(data: convData)
        return ref.documentID
    }
    
    static func sendMessage(
        conversationId: String, senderId: String, text: String
    ) async throws {
        let db = Firestore.firestore()
        let msgData: [String: Any] = [
            "senderId": senderId,
            "text": text,
            "timestamp": Timestamp()
        ]
        try await db.collection("conversations").document(conversationId)
            .collection("messages").addDocument(data: msgData)
        try await db.collection("conversations").document(conversationId)
            .updateData([
                "lastMessage": text,
                "lastMessageDate": Timestamp()
            ])
    }
    
    static func fetchConversations(uid: String) async throws -> [Conversation] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("conversations")
            .whereField("participants", arrayContains: uid)
            .order(by: "lastMessageDate", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            return Conversation(
                id: doc.documentID,
                participants: d["participants"] as? [String] ?? [],
                lastMessage: d["lastMessage"] as? String ?? "",
                lastMessageDate: (d["lastMessageDate"] as? Timestamp)?.dateValue() ?? Date(),
                otherUsername: nil
            )
        }
    }
}
