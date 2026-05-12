//
//  CreatePostScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI
import PhotosUI

struct CreatePostScreen: View {
    @Environment(UserStore.self) var userStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var caption = ""
    @State private var isPosting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let data = imageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 200)
                            .overlay {
                                Label("Choose Photo", systemImage: "photo.badge.plus")
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                
                TextField("Write a caption...", text: $caption, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .background(.gray.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 12))
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task { await createPost() }
                    }
                    .disabled(imageData == nil || isPosting)
                }
            }
            .overlay {
                if isPosting {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Posting...")
                            .font(.subheadline)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .onChange(of: selectedItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(
                        type: Data.self
                    ) {
                        if let uiImage = UIImage(data: data),
                           let compressed = uiImage.jpegData(
                            compressionQuality: 0.8
                           ) {
                            imageData = compressed
                        }
                    }
                }
            }
        }
    }
    
    func createPost() async {
        guard let imageData,
              let user = userStore.currentUser else { return }
        isPosting = true
        errorMessage = nil
        do {
            try await PostService.createPost(
                userId: user.id,
                username: user.username,
                profileImageUrl: user.profileImageUrl,
                imageData: imageData,
                caption: caption
            )
            
            userStore.currentUser?.postCount += 1
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isPosting = false
    }
}
