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
        // Configure Firebase FIRST before any other initialization
        configureFirebase()
    }
    
    private func configureFirebase() {
        // Only configure if not already configured
        guard FirebaseApp.app() == nil else {
            print("✅ Firebase already configured")
            return
        }
        
        // Try to find GoogleService-Info.plist (or any variation)
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            // Found exact name
            FirebaseApp.configure()
            print("✅ Firebase configured with GoogleService-Info.plist")
        } else if let path = Bundle.main.path(forResource: "GoogleService-Info (1)", ofType: "plist") {
            // Found with (1) suffix - configure with specific path
            guard let options = FirebaseOptions(contentsOfFile: path) else {
                print("⚠️ Could not load Firebase options from plist")
                fatalError("Firebase configuration file found but could not be loaded. Please check GoogleService-Info.plist is valid.")
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
            // If we get here, no plist file was found
            fatalError("""
            Firebase configuration file (GoogleService-Info.plist) not found.
            
            To fix this:
            1. Download GoogleService-Info.plist from your Firebase Console
            2. Add it to your Xcode project (make sure it's added to the app target)
            3. Ensure it's included in the app bundle
            
            The app cannot run without Firebase configuration.
            """)
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
                print("🔗 [FrothApp] App opened with URL: \(url.absoluteString)")
                if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
                    // This is a sign-in link (passwordless), handle it if needed
                    print("✅ [FrothApp] Sign-in link detected")
                } else {
                    // This is likely an email verification link
                    // Apply the action code to verify the email
                    Task { @MainActor in
                        print("🔗 [FrothApp] Processing verification link...")
                        await verificationService.handleVerificationLink(url: url)
                        // Post notification immediately to trigger verification check in EmailVerificationView
                        // This will cause the view to automatically check and dismiss if verified
                        print("📢 [FrothApp] Posting EmailVerificationLinkOpened notification")
                        NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                        
                        // Also check verification status directly after a brief moment
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        await verificationService.checkVerificationStatus()
                        // Post notification again to ensure it's caught
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
                    print("📱 [FrothApp] App became active - checking verification status immediately...")
                    
                    if let user = Auth.auth().currentUser {
                        // Check immediately - no delay
                        do {
                            print("🔄 [FrothApp] Reloading user to get latest verification status...")
                            try await user.reload()
                            print("✅ [FrothApp] User reloaded. Verified: \(user.isEmailVerified)")
                            
                            // Update verification service status immediately
                            await verificationService.checkVerificationStatus()
                            
                            // Post notification immediately to trigger check in EmailVerificationView
                            print("📢 [FrothApp] Posting EmailVerificationLinkOpened notification...")
                            NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                            
                            // Check again after short delays to ensure we catch it
                            for i in 1...3 {
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                print("🔄 [FrothApp] Re-checking verification status (attempt \(i))...")
                                try? await user.reload()
                                await verificationService.checkVerificationStatus()
                                NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                                
                                // If verified, we can stop checking
                                if verificationService.isEmailVerified {
                                    print("✅ [FrothApp] Verification detected! Stopping checks.")
                                    break
                                }
                            }
                        } catch {
                            print("⚠️ [FrothApp] Error reloading user when app became active: \(error.localizedDescription)")
                            // Still try to check verification status
                            await verificationService.checkVerificationStatus()
                            NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                        }
                    } else {
                        // No user signed in - this might mean the session expired
                        // If we have an email in the store, the user might have verified but isn't signed in
                        if !store.email.isEmpty {
                            print("⚠️ [FrothApp] No user signed in but email exists in store: \(store.email)")
                            print("💡 [FrothApp] User may have verified email but session expired. They may need to sign in.")
                            // Still post notification so EmailVerificationView can handle it
                            NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                        }
                    }
                }
            }
        }
    }
}
