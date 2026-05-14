//
//  MainTabView.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var showCreatePost = false
    
    var body: some View {
        TabView {
            NavigationStack {
                FeedScreen()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showCreatePost = true
                            } label: {
                                Image(systemName: "plus.app")
                                    .font(.title2)
                            }
                        }
                    }
            }
            .tabItem { Label("Home", systemImage: "house") }
            
            NavigationStack {
                ProfileScreen()
            }
            .tabItem { Label("Profile", systemImage: "person") }
            
            NavigationStack {
                ConversationsListScreen()
            }
            .tabItem {
                Label("Messages", systemImage: "bubble.left.and.bubble.right")
            }
            
            NavigationStack {
                SearchUsersScreen()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostScreen()
        }
    }
}
