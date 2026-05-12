//
//  PostGridView.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI

struct PostGridView: View {
    let posts: [Post]
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(posts) { post in
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.red.opacity(0.2)
                            .overlay {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.red)
                            }
                    case .empty:
                        Color.gray.opacity(0.2)
                            .overlay { ProgressView() }
                    @unknown default:
                        Color.gray.opacity(0.2)
                    }
                }
                .aspectRatio(1, contentMode: .fill)
                .clipped()
            }
        }
    }
}

#Preview {
    PostGridView(posts: [
        Post(id: "1", userId: "abc", username: "testuser", userProfileImageUrl: nil,
             imageUrl: "https://picsum.photos/400/400", caption: "First post",
             likeCount: 5, commentCount: 2, datePosted: .now),
        Post(id: "2", userId: "abc", username: "testuser", userProfileImageUrl: nil,
             imageUrl: "https://picsum.photos/401/401", caption: "Second post",
             likeCount: 3, commentCount: 0, datePosted: .now),
        Post(id: "3", userId: "abc", username: "testuser", userProfileImageUrl: nil,
             imageUrl: "https://picsum.photos/402/402", caption: "Third post",
             likeCount: 12, commentCount: 4, datePosted: .now),
    ])
}
