//
//  SignUpScreen.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI

struct SignUpScreen: View {
    @Environment(AuthManager.self) var authManager
    @Binding var showSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 50))
                Text("Create Account").font(.title.bold())
            }
            Spacer()
            VStack(spacing: 14) {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                SecureField("Password (6+ characters)", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 32)
            if let error = authManager.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
                    .padding(.horizontal, 32)
            }
            Button {
                Task { await authManager.signUp(email: email, password: password, username: username) }
            } label: {
                if authManager.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Sign Up").font(.headline).frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .disabled(username.count < 3 || email.isEmpty || authManager.isLoading || password.count < 6)
            Spacer()
            Button {
                showSignUp = false
                authManager.errorMessage = nil
            } label: {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundStyle(.secondary)
                    Text("Log In")
                        .bold()
                }
                .font(.subheadline)
            }
        }
    }
}
