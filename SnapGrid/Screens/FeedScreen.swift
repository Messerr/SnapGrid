//
//  FeedScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI

struct FeedScreen: View {
    @Environment(UserStore.self) var userStore
    @State private var posts: [Post] = []
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else if posts.isEmpty {
                ContentUnavailableView(
                    "No Posts Yet",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("Posts from the community will appear here")
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(posts) { post in
                        PostCard(post: post, currentUserId: userStore.currentUser?.id)
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("Home")
        .task {
            await loadFeed()
        }
        .refreshable {
            await loadFeed()
        }
    }
    
    func loadFeed() async {
        do {
            if let uid = userStore.currentUser?.id {
                posts = try await PostService.fetchFollowedFeedPosts(userId: uid)
            }
            
            if posts.isEmpty {
                posts = try await PostService.fetchFeedPosts()
            }
        } catch {
            print("Feed error: \(error)")
        }
        isLoading = false
    }
}
