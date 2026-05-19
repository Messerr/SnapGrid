//
//  ProfileScreen.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI

struct ProfileScreen: View {
    @Environment(UserStore.self) var userStore
    @Environment(AuthManager.self) var authManager
    @State private var showEditProfile = false
    @State private var posts: [Post] = []
    @State private var followerIds: [String] = []
    @State private var followingIds: [String] = []
    
    var body: some View {
        if let user = userStore.currentUser {
            ScrollView {
                VStack(spacing: 0) {
                    if let url = user.profileImageUrl, let imageUrl = URL(string: url) {
                        AsyncImage(url: imageUrl) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                            }
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
                    
                    Button("Edit Profile") { showEditProfile = true }
                        .buttonStyle(.bordered)
                        .padding(.top, 12)
                    
                    HStack(spacing: 32) {
                        StatColumn(value: user.postCount, label: "Posts")
                        NavigationLink(destination: UserListScreen(title: "Followers", userIds: followerIds)) {
                            StatColumn(value: user.followerCount, label: "Followers")
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: UserListScreen(title: "Following", userIds: followingIds)) {
                            StatColumn(value: user.followingCount, label: "Following")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 16)
                    
                    Divider()
                    
                    PostGridView(posts: posts)
                }
                .padding(.top)
            }
            .task {
                await loadPosts()
                followerIds = (try? await FollowService.getFollowerIds(uid: user.id)) ?? []
                followingIds = (try? await FollowService.getFollowingIds(uid: user.id)) ?? []
            }
            .refreshable {
                await loadPosts()
                await userStore.loadCurrentUser()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        authManager.signOut()
                    }
                }
            }
        } else {
            ProgressView("Loading profile...")
        }
    }
    
    func loadPosts() async {
        guard let uid = userStore.currentUser?.id else { return }
        posts = (try? await PostService.fetchUserPosts(userId: uid)) ?? []
    }
}
