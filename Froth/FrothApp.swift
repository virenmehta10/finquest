//
//  FrothApp.swift
//  Froth
//
//  Created by Viren Mehta on 9/15/25.
//

import SwiftUI
import Combine
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Safely configure Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
}

@main
struct FrothApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var store = AppStore.load()
    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated && authService.isEmailVerified {
                    // User is authenticated and email is verified - show main app
                    ZStack {
                        AnimatedGradientBackgroundWithSplashes()
                        ContentView()
                    }
                    .environmentObject(store)
                    .preferredColorScheme(store.selectedTheme.colorScheme)
                    .buttonStyle(SoftDefaultButtonStyle())
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        // Only check and reset daily goals when app becomes active if needed
                        // This prevents redundant calls when the app is already running
                        if store.dailyGoals.isEmpty || store.lastDailyGoalResetDate == nil {
                            store.checkAndResetDailyGoals()
                        }
                    }
                } else if authService.isAuthenticated && !authService.isEmailVerified {
                    // User is authenticated but email not verified - show verification screen
                    EmailVerificationView(authService: authService)
                } else {
                    // User not authenticated - show authentication screens
                    AuthenticationView()
                }
            }
            .environmentObject(authService)
        }
    }
}
