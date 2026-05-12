//
//  AppUser.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    var id: String
    var username: String
    var email: String
    var bio: String
    var profileImageUrl: String?
    var dateJoined: Date
    var followerCount: Int
    var followingCount: Int
    var postCount: Int
}
