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
    @State private var vm = ChatViewModel()
    @State private var newMessage = ""
    @State private var isSending = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.messages) { msg in
                            MessageBubble(
                                text: msg.text,
                                isFromMe: msg.senderId == currentUserId,
                                timestamp: msg.timestamp
                            )
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
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
        currentUserId: "abc"
    )
}
