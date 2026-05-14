//
//  Message.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import Foundation

struct Message: Identifiable {
    let id: String
    let senderId: String
    let text: String
    let timestamp: Date
}
