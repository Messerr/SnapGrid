//
//  PostCard.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI

struct PostCard: View {
    let post: Post
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                Button { } label: {
                    Image(systemName: "heart")
                        .font(.title3)
                }
                Button { } label: {
                    Image(systemName: "bubble.right")
                        .font(.title3)
                }
                Spacer()
            }
            .foregroundStyle(.primary)
            .padding(.horizontal)
            
            if post.likeCount > 0 {
                Text("\(post.likeCount) likes")
                    .font(.subheadline.bold())
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
    ))
}
