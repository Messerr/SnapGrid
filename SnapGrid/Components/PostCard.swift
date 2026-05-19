//
//  PostCard.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI

struct PostCard: View {
    let post: Post
    let currentUserId: String?
    @State private var isLiked = false
    @State private var likeCount: Int = 0
    @State private var heartScale: CGFloat = 1.0
    @State private var showComments = false
    @State private var commentCount: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: UserProfileScreen(userId: post.userId)) {
                HStack {
                    AsyncImage(url: URL(string: post.userProfileImageUrl ?? "")) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(.gray.opacity(0.3))
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    Text(post.username)
                        .font(.subheadline.bold())
                    Spacer()
                }
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
            AsyncImage(url: URL(string: post.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Color.gray.opacity(0.2)
                        .frame(height: 300)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                case .empty:
                    Color.gray.opacity(0.1)
                        .frame(height: 300)
                        .overlay { ProgressView() }
                @unknown default:
                    Color.gray.opacity(0.1)
                        .frame(height: 300)
                }
            }
            HStack(spacing: 16) {
                Button {
                    Task { await toggleLike() }
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isLiked ? .red : .primary)
                        .scaleEffect(heartScale)
                }
                Button { showComments = true } label: {
                    Image(systemName: "bubble.right")
                        .font(.title3)
                }
                Spacer()
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
            
            if likeCount > 0 {
                Text("\(likeCount) likes")
                    .font(.subheadline.bold())
                    .padding(.horizontal)
            }
            
            if commentCount > 0 {
                Button {
                    showComments = true
                } label: {
                    Text("View all \(commentCount) comments")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            
            if !post.caption.isEmpty {
                HStack {
                    Text(post.username)
                        .font(.subheadline.bold())
                    Text(post.caption)
                        .font(.subheadline)
                }
                .padding(.horizontal)
            }
            
            Text(post.datePosted, format: .relative(presentation: .named))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showComments) {
            CommentsScreen(postId: post.id)
        }
        .onAppear {
            likeCount = post.likeCount
            commentCount = post.commentCount
        }
        .task {
            guard let uid = currentUserId else { return }
            isLiked = await LikeService.hasLiked(
                postId: post.id, userId: uid
            )
        }
    }
    
    func toggleLike() async {
        guard let uid = currentUserId else { return }
        do {
            if isLiked {
                try await LikeService.unlikePost(
                    postId: post.id,
                    userId: uid
                )
                isLiked = false
                likeCount -= 1
            } else {
                try await LikeService.likePost(
                    postId: post.id,
                    userId: uid
                )
                isLiked = true
                likeCount += 1
                withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                    heartScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(duration: 0.2)) {
                        heartScale = 1.0
                    }
                }
            }
        } catch {
            print("Like error: \(error)")
        }
    }
}

#Preview {
    PostCard(post: Post(
        id: "1",
        userId: "abc",
        username: "thisisatestuser",
        userProfileImageUrl: nil,
        imageUrl: "https://picsum.photos/600/600",
        caption: "Beautiful day outside!",
        likeCount: 42,
        commentCount: 5,
        datePosted: .now.addingTimeInterval(-3600)
    ),
        currentUserId: "xyz"
    )
}
