//
//  Post.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import Foundation
import FirebaseFirestore

struct Post: Codable, Identifiable {
    var id: String
    var userId: String
    var username: String
    var userProfileImageUrl: String?
    var imageUrl: String
    var caption: String
    var likeCount: Int
    var commentCount: Int
    var datePosted: Date
}
