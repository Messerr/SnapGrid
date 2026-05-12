//
//  AuthManager.swift
//  SnapGrid
//
//  Created by David Messer on 5/10/26.
//

import Foundation
import FirebaseAuth

@Observable
class AuthManager {
    var user: FirebaseAuth.User?
    var isLoggedIn: Bool { user != nil }
    var errorMessage: String?
    var isLoading = false
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )
            
            try await UserService.createUserDocument(
                uid: result.user.uid,
                username: username,
                email: email
            )
            self.user = result.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            self.user = result.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
