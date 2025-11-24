//
//  FrothApp.swift
//  Froth
//
//  Created by Viren Mehta on 9/15/25.
//

import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth

@main
struct FrothApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = AppStore.load()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background that matches preview exactly
                AnimatedGradientBackgroundWithSplashes()
                    .ignoresSafeArea(.all)
                
                ContentView()
            }
            .environmentObject(store)
            .preferredColorScheme(.light)
            .buttonStyle(SoftDefaultButtonStyle())
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if store.dailyGoals.isEmpty || store.lastDailyGoalResetDate == nil {
                    store.checkAndResetDailyGoals()
                }
            }
        }
    }
}
