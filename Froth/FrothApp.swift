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
    @StateObject private var store = AppStore.load()
    @StateObject private var verificationService = EmailVerificationService()
    
    init() {
        // Configure Firebase - check for plist file in bundle
        if FirebaseApp.app() == nil {
            // Try to find GoogleService-Info.plist (or any variation)
            if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                // Found exact name
                FirebaseApp.configure()
                print("✅ Firebase configured with GoogleService-Info.plist")
            } else if let path = Bundle.main.path(forResource: "GoogleService-Info (1)", ofType: "plist") {
                // Found with (1) suffix - configure with specific path
                guard let options = FirebaseOptions(contentsOfFile: path) else {
                    print("⚠️ Could not load Firebase options from plist")
                    return
                }
                FirebaseApp.configure(options: options)
                print("✅ Firebase configured with GoogleService-Info (1).plist")
            } else {
                // Try to find any plist file that might be the Firebase config
                if let resourcePath = Bundle.main.resourcePath {
                    let fileManager = FileManager.default
                    if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                        for file in files {
                            if file.contains("GoogleService") && file.hasSuffix(".plist") {
                                let fullPath = (resourcePath as NSString).appendingPathComponent(file)
                                if let options = FirebaseOptions(contentsOfFile: fullPath) {
                                    FirebaseApp.configure(options: options)
                                    print("✅ Firebase configured with \(file)")
                                    return
                                }
                            }
                        }
                    }
                }
                print("⚠️ GoogleService-Info.plist not found - Firebase features disabled")
            }
        }
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
            .onOpenURL { url in
                // Handle Firebase email verification links
                print("🔗 App opened with URL: \(url.absoluteString)")
                if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
                    // This is a sign-in link (passwordless), handle it if needed
                    print("✅ Sign-in link detected")
                } else {
                    // This is likely an email verification link
                    // Apply the action code to verify the email
                    Task { @MainActor in
                        await verificationService.handleVerificationLink(url: url)
                        // Post notification to trigger verification check in EmailVerificationView
                        NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Only check and reset daily goals when app becomes active if needed
                // This prevents redundant calls when the app is already running
                if store.dailyGoals.isEmpty || store.lastDailyGoalResetDate == nil {
                    store.checkAndResetDailyGoals()
                }
                
                // Check email verification status when app becomes active (user might have clicked link)
                Task { @MainActor in
                    // Wait a moment for Firebase to process the verification
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    
                    if let user = Auth.auth().currentUser {
                        do {
                            try await user.reload()
                            print("✅ User reloaded when app became active. Verified: \(user.isEmailVerified)")
                            // Update verification service status
                            await verificationService.checkVerificationStatus()
                            
                            // Post notification to trigger verification check in EmailVerificationView
                            // Post it multiple times with delays to ensure it's caught
                            NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                            
                            // Post again after a delay
                            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                            await verificationService.checkVerificationStatus()
                            NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                            
                            // Post one more time
                            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                            await verificationService.checkVerificationStatus()
                            NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                        } catch {
                            print("⚠️ Error reloading user when app became active: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
