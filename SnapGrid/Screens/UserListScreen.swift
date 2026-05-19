//
//  UserListScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import SwiftUI

struct UserListScreen: View {
    let title: String
    let userIds: [String]
    @State private var users: [AppUser] = []
    
    var body: some View {
        List(users) { user in
            NavigationLink(destination: UserProfileScreen(userId: user.id)) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    Text(user.username)
                        .font(.subheadline.bold())
                }
            }
        }
        .navigationTitle(title)
        .task {
            users = []
            for uid in userIds {
                if let user = try? await UserService.fetchUser(uid: uid) {
                    users.append(user)
                }
            }
        }
    }
}
