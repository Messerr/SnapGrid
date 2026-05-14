//
//  ChatViewModel.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import Foundation
import FirebaseFirestore

@Observable
class ChatViewModel {
    var messages: [Message] = []
    private var listener: ListenerRegistration?
    
    func startListening(conversationId: String) {
        let db = Firestore.firestore()
        listener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { doc in
                    let d = doc.data()
                    return Message(
                        id: doc.documentID,
                        senderId: d["senderId"] as? String ?? "",
                        text: d["text"] as? String ?? "",
                        timestamp: (d["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
