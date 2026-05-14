//
//  ContentView.swift
//  SnapGrid
//
//  Created by David Messer on 5/10/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var authManager = AuthManager()
    @State private var userStore = UserStore()
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainTabView()
                    .task { await userStore.loadCurrentUser() }
            } else {
                AuthScreen()
                    .onAppear { userStore.currentUser = nil }
            }
        }
        .environment(authManager)
        .environment(userStore)
    }
}
