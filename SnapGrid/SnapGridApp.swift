//
//  SnapGridApp.swift
//  SnapGrid
//
//  Created by David Messer on 5/10/26.
//

import SwiftUI
import FirebaseCore
// AppDelegate initializes Firebase when the app launches.
// Firebase requires this UIKit pattern to configure before SwiftUI starts.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // This reads GoogleService-Info.plist and connects to Firebase
        FirebaseApp.configure()
        return true
    }
}
@main
struct SnapGridApp: App {
    // Bridges UIKit's AppDelegate into SwiftUI
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
