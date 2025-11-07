//
//  FrothApp.swift
//  Froth
//
//  Created by Viren Mehta on 9/15/25.
//

import SwiftUI
import Combine
import FirebaseCore

@main
struct FrothApp: App {
    @StateObject private var store = AppStore.load()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
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
        }
    }
}
