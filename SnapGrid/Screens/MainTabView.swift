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
                Text("Feed coming soon")
                    .navigationTitle("Home")
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
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostScreen()
        }
    }
}

#Preview {
    MainTabView()
}
