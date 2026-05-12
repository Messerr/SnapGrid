//
//  LoginScreen.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI

struct LoginScreen: View {
    @Environment(AuthManager.self) var authManager
    @Binding var showSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 50))
                Text("SnapGrid")
                    .font(.largeTitle.bold())
            }
            Spacer()
            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 32)
            if let error = authManager.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
                    .padding(.horizontal, 32)
            }
            Button {
                Task { await authManager.signIn(email: email, password: password) }
            } label: {
                if authManager.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Log In").font(.headline).frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
            Spacer()
            Button {
                showSignUp = true
                authManager.errorMessage = nil
            } label: {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Text("Sign Up")
                        .bold()
                }
                .font(.subheadline)
            }
        }
    }
}

#Preview {
    @Previewable @State var showSignUp = true
    
    LoginScreen(
        showSignUp: $showSignUp
    )
}
