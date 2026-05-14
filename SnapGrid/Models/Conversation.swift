//
//  Conversation.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import Foundation

struct Conversation: Identifiable {
    let id: String
    let participants: [String]
    var lastMessage: String
    var lastMessageDate: Date
    var otherUsername: String?
}
