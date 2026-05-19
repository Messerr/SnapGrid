//
//  ConversationsListScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import SwiftUI

struct ConversationsListScreen: View {
    @Environment(UserStore.self) var userStore
    @State private var conversations: [Conversation] = []
    @State private var isLoading = true
    @State private var otherUsers: [String: AppUser] = [:]
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if conversations.isEmpty {
                ContentUnavailableView(
                    "No Messages",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Start a conversation from someone's profile")
                )
            } else {
                List(conversations) { convo in
                    NavigationLink(destination: ChatScreen(
                        conversationId: convo.id,
                        currentUserId: userStore.currentUser?.id ?? "",
                        otherUserName: convo.otherUsername,
                        otherProfileImageUrl: otherUsers[convo.id]?.profileImageUrl,
                        otherUserId: otherUsers[convo.id]?.id ?? ""
                    )) {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: otherUsers[convo.id]?.profileImageUrl ?? "")) { img in
                                img.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(.gray.opacity(0.3))
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(convo.otherUsername ?? "Unknown")
                                    .font(.subheadline.bold())
                                Text(convo.lastMessage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Messages")
        .task {
            await loadConversations()
        }
        .refreshable {
            await loadConversations()
        }
    }
    
    func loadConversations() async {
        guard let uid = userStore.currentUser?.id else { return }
        do {
            var convos = try await ChatService.fetchConversations(uid: uid)
            for i in convos.indices {
                let otherUid = convos[i].participants.first { $0 != uid } ?? ""
                if let otherUser = try? await UserService.fetchUser(uid: otherUid) {
                    convos[i].otherUsername = otherUser.username
                    otherUsers[convos[i].id] = otherUser
                }
            }
            conversations = convos
        } catch {
            print("Conversations error: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    ConversationsListScreen()
}
