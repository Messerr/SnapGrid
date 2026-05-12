//
//  UserStore.swift
//  SnapGrid
//
//  Created by messerd on 5/11/26.
//

import Foundation
import FirebaseAuth

@Observable
class UserStore {
    var currentUser: AppUser?
    func loadCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            currentUser = try await UserService.fetchUser(uid: uid)
        } catch {
            print("Failed to load user \(error)")
        }
    }
}
