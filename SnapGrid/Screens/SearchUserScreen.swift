//
//  SearchUserScreen.swift
//  SnapGrid
//
//  Created by David Messer on 5/11/26.
//

import SwiftUI

struct SearchUsersScreen: View {
    @Environment(UserStore.self) var userStore
    @State private var searchText = ""
    @State private var results: [AppUser] = []
    var body: some View {
        List(results) { user in
            NavigationLink(destination: UserProfileScreen(userId: user.id)) {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(.subheadline.bold())
                        if !user.bio.isEmpty {
                            Text(user.bio)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Search by username...")
        .task(id: searchText) {
            guard !searchText.isEmpty else {
                results = []
                return
            }
            do {
                try await Task.sleep(for: .milliseconds(400))
                let all = try await UserService.searchUsers(query: searchText)
                results = all.filter { $0.id != userStore.currentUser?.id }
            } catch is CancellationError {
                // user typed again — debounce working
            } catch {
                print("Search error: \(error)")
            }
        }
    }
}
