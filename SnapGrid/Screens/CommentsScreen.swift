//
//  CommentsScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import SwiftUI

struct CommentsScreen: View {
    let postId: String
    @Environment(UserStore.self) var userStore
    @State private var comments: [Comment] = []
    @State private var newComment = ""
    @State private var isSending = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List(comments) { comment in
                    HStack(alignment: .top, spacing: 10) {
                        AsyncImage(url: URL(string: comment.userProfileImage ?? "")) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle().fill(.gray.opacity(0.3))
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(comment.username)
                                    .font(.subheadline.bold())
                                Spacer()
                                Text(comment.timestamp, format: .relative(presentation: .named))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            Text(comment.text)
                                .font(.subheadline)
                        }
                    }
                }
                .listStyle(.plain)
                
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        Task { await sendComment() }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.blue)
                    }
                    .disabled(newComment.isEmpty || isSending)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadComments()
            }
        }
    }
    
    func loadComments() async {
        comments = (try? await CommentService.fetchComments(postId: postId)) ?? []
    }
    
    func sendComment() async {
        guard let user = userStore.currentUser,
              !newComment.isEmpty else { return }
        isSending = true
        do {
            try await CommentService.addComment(
                postId: postId,
                userId: user.id,
                username: user.username,
                profileImageUrl: user.profileImageUrl,
                text: newComment
            )
            newComment = ""
            await loadComments()
        } catch {
            print("Comment error \(error)")
        }
        isSending = false
    }
}
