//
//  EditUserScreen.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI
import PhotosUI

struct EditProfileSheet: View {
    @Environment(UserStore.self) var userStore
    @Environment(\.dismiss) var dismiss
    @State private var bio = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isSaving = false
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Photo") {
                    HStack {
                        if let data = imageData, let img = UIImage(data: data) {
                            Image(uiImage: img)
                                .resizable().aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else if let url = userStore.currentUser?.profileImageUrl {
                            AsyncImage(url: URL(string: url)) { img in
                                img.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: { Circle().fill(.gray.opacity(0.3)) }
                            .frame(width: 60, height: 60).clipShape(Circle())
                        } else {
                            Circle().fill(.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay { Image(systemName: "person.fill").foregroundStyle(.gray) }
                        }
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Change Photo")
                        }
                    }
                }
                Section("Bio") {
                    TextField("Write something about yourself...", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await saveProfile() } }
                        .disabled(isSaving)
                }
            }
            .onAppear { bio = userStore.currentUser?.bio ?? "" }
            .onChange(of: selectedItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data),
                       let compressed = img.jpegData(compressionQuality: 0.7) {
                        imageData = compressed
                    }
                }
            }
            .overlay {
                if isSaving { ProgressView("Saving...").padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12)) }
            }
        }
    }
    func saveProfile() async {
        guard let uid = userStore.currentUser?.id else { return }
        isSaving = true
        var profileUrl = userStore.currentUser?.profileImageUrl
        if let data = imageData {
            profileUrl = try? await StorageService.uploadProfileImage(
                uid: uid, imageData: data
            )
        }
        do {
            try await UserService.updateProfile(
                uid: uid, bio: bio, profileImageUrl: profileUrl
            )
            userStore.currentUser?.bio = bio
            if let url = profileUrl { userStore.currentUser?.profileImageUrl = url }
            dismiss()
        } catch { print("Update failed: \(error)") }
        isSaving = false
    }
}
