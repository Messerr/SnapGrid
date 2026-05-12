//
//  AuthScreen.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import SwiftUI

struct AuthScreen: View {
    @State private var showSignUp = false
    
    var body: some View {
        if showSignUp {
            SignUpScreen(showSignUp: $showSignUp)
        } else {
            LoginScreen(showSignUp: $showSignUp)
        }
    }
}

#Preview {
    AuthScreen()
}
