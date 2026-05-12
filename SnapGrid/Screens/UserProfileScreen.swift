//
//  UserProfileScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI

struct UserProfileScreen: View {
    let userId: String
    @Environment(UserStore.self) var userStore
    @State private var user: AppUser?
    @State private var posts: [Post] = []
    @State private var isFollowing = false
    @State private var isLoading = true
    var body: some View {
        ScrollView {
            if let user {
                VStack(spacing: 0) {
                    // Avatar
                    if let url = user.profileImageUrl, let imageUrl = URL(string: url) {
                        AsyncImage(url: imageUrl) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: { ProgressView() }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Circle().fill(.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay { Image(systemName: "person.fill")
                                .font(.largeTitle).foregroundStyle(.gray) }
                    }
                    Text(user.username)
                        .font(.title2.bold())
                        .padding(.top, 12)
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    if isFollowing {
                        Button {
                            Task { await toggleFollow() }
                        } label: {
                            Text("Following")
                                .font(.subheadline.bold())
                                .frame(width: 140)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 12)
                    } else {
                        Button {
                            Task { await toggleFollow() }
                        } label: {
                            Text("Follow")
                                .font(.subheadline.bold())
                                .frame(width: 140)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 12)
                    }
                    HStack(spacing: 32) {
                        StatColumn(value: user.postCount, label: "Posts")
                        StatColumn(value: user.followerCount, label: "Followers")
                        StatColumn(value: user.followingCount, label: "Following")
                    }
                    .padding(.vertical, 16)
                    Divider()
                    PostGridView(posts: posts)
                }
                .padding(.top)
            } else if isLoading {
                ProgressView("Loading profile...")
                    .padding(.top, 40)
            }
        }
        .navigationTitle(user?.username ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadProfile()
        }
    }
    func loadProfile() async {
        do {
            user = try await UserService.fetchUser(uid: userId)
            posts = try await PostService.fetchUserPosts(userId: userId)
            if let currentUid = userStore.currentUser?.id {
                isFollowing = await FollowService.isFollowing(
                    currentUid: currentUid, targetUid: userId
                )
            }
        } catch {
            print("Error loading profile: \(error)")
        }
        isLoading = false
    }
    func toggleFollow() async {
        guard let currentUid = userStore.currentUser?.id else { return }
        do {
            if isFollowing {
                try await FollowService.unfollow(
                    currentUid: currentUid, targetUid: userId
                )
                isFollowing = false
                user?.followerCount -= 1
                userStore.currentUser?.followingCount -= 1
            } else {
                try await FollowService.follow(
                    currentUid: currentUid, targetUid: userId
                )
                isFollowing = true
                user?.followerCount += 1
                userStore.currentUser?.followingCount += 1
            }
        } catch {
            print("Follow error: \(error)")
        }
    }
}
