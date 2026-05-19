//
//  ChatScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/13/26.
//

import SwiftUI

struct ChatScreen: View {
    let conversationId: String
    let currentUserId: String
    let otherUserName: String?
    let otherProfileImageUrl: String?
    let otherUserId: String
    @State private var vm = ChatViewModel()
    @State private var newMessage = ""
    @State private var isSending = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.messages) { msg in
                            HStack {
                                if msg.senderId == currentUserId { Spacer() }
                                
                                MessageBubble(
                                    text: msg.text,
                                    isFromMe: msg.senderId == currentUserId
                                )
                                
                                if msg.senderId != currentUserId { Spacer() }
                            }
                            .overlay(alignment: .trailing) {
                                if dragOffset < -10 {
                                    Text(msg.timestamp, format: .dateTime.hour().minute())
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                        .offset(x: 55)
                                        .transition(.opacity)
                                }
                            }
                            .offset(x: dragOffset)
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            if value.translation.width < 0 {
                                withAnimation(.interactiveSpring) {
                                    dragOffset = max(value.translation.width, -60)
                                }
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(duration: 0.3)) {
                                dragOffset = 0
                            }
                        }
                )
                .onChange(of: vm.messages.count) {
                    if let last = vm.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            Divider()
            HStack {
                TextField("Message...", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await sendMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.blue)
                }
                .disabled(newMessage.isEmpty || isSending)
            }
            .padding()
        }
        .onAppear { vm.startListening(conversationId: conversationId) }
        .onDisappear { vm.stopListening() }
        .toolbar {
            ToolbarItem(placement: .principal) {
                NavigationLink(destination: UserProfileScreen(userId: otherUserId)) {
                    HStack {
                        AsyncImage(url: URL(string: otherProfileImageUrl ?? "")) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle().fill(.gray.opacity(0.3))
                        }
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                        Text(otherUserName ?? "Chat")
                            .font(.subheadline.bold())
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func sendMessage() async {
        let text = newMessage
        newMessage = ""
        isSending = true
        do {
            try await ChatService.sendMessage(
                conversationId: conversationId,
                senderId: currentUserId,
                text: text
            )
        } catch {
            print("Send error: \(error)")
        }
        isSending = false
    }
}

#Preview {
    ChatScreen(
        conversationId: "xyz",
        currentUserId: "abc",
        otherUserName: "zzzzz",
        otherProfileImageUrl: "",
        otherUserId: "uuuuu"
    )
}
