//
//  EmailVerificationService.swift
//  Froth
//
//  Email verification service using Firebase Authentication
//

import Foundation
import FirebaseAuth
import FirebaseCore
import Combine

@MainActor
class EmailVerificationService: ObservableObject {
    @Published var isEmailVerified = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastEmailSentDate: Date?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        // Only setup auth listener if Firebase is configured
        if FirebaseApp.app() != nil {
            // Ensure Firebase Auth persists sessions (this is the default, but being explicit)
            // Firebase Auth automatically persists sessions by default on iOS
            setupAuthStateListener()
            
            // Check if there's already a signed-in user when service initializes
            if let user = Auth.auth().currentUser {
                print("✅ User already signed in on service init: \(user.uid)")
                // Check verification status for existing user
                Task {
                    await checkVerificationStatus()
                }
            }
        }
    }
    
    deinit {
        if let listener = authStateListener, FirebaseApp.app() != nil {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        // Double check Firebase is configured before accessing Auth
        guard FirebaseApp.app() != nil else {
            print("⚠️ Firebase not configured - skipping auth state listener")
            return
        }
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                guard let self = self else { return }
                if let user = user {
                    // Reload user to get latest verification status when auth state changes
                    do {
                        try await user.reload()
                        self.isEmailVerified = user.isEmailVerified
                        if user.isEmailVerified {
                            print("✅ Auth state changed: User email is verified")
                        }
                    } catch {
                        print("⚠️ Error reloading user in auth state listener: \(error.localizedDescription)")
                        self.isEmailVerified = user.isEmailVerified
                    }
                } else {
                    self.isEmailVerified = false
                }
            }
        }
    }
    
    func createAccount(email: String, password: String, username: String) async throws -> String {
        // Check Firebase is configured
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "EmailVerificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured. Please check GoogleService-Info.plist is in the project."])
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Create Firebase user account
            // Firebase will throw emailAlreadyInUse if the email actually exists
            // We removed the deprecated fetchSignInMethods pre-check and rely on Firebase's error handling
            print("🔵 Creating Firebase account for: \(email)")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // If we get here, account was created successfully
            print("✅ Account created successfully: \(result.user.uid)")
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = username
            try await changeRequest.commitChanges()
            print("✅ Display name updated: \(username)")
            
            // Send verification email with proper iOS configuration
            print("📧 Preparing to send verification email to: \(email)")
            print("📧 User UID: \(result.user.uid)")
            
            // Configure ActionCodeSettings with iOS bundle ID (required for iOS)
            let actionCodeSettings = ActionCodeSettings()
            // Use a URL that will redirect to the app
            actionCodeSettings.url = URL(string: "https://alpha-1bd67.firebaseapp.com")
            // Set to false - let it open in browser first, then redirect to app
            // This is more reliable and avoids "operation not valid" errors
            actionCodeSettings.handleCodeInApp = false
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            
            // Send verification email - ONLY call once (calling twice causes rate-limiting)
            try await result.user.sendEmailVerification(with: actionCodeSettings)
            print("✅ Firebase API confirmed verification email request was accepted")
            print("📧 Verification email sent successfully")
            print("📧 Email should arrive at: \(email)")
            print("📧 Check spam folder if not in inbox")
            
            lastEmailSentDate = Date()
            
            return result.user.uid
        } catch {
            print("❌ Error creating account or sending email: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ Error code: \(nsError.code), domain: \(nsError.domain)")
                print("❌ User info: \(nsError.userInfo)")
                
                // If Firebase says email already in use, enforce sign-in requirement
                // This is the authoritative check - Firebase knows for sure if email exists
                if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    let errorMsg = "This email is already registered. Please sign in instead."
                    self.errorMessage = errorMsg
                    print("❌ BLOCKED: Firebase confirmed email already exists (authoritative check)")
                    throw NSError(domain: "EmailVerificationService", code: AuthErrorCode.emailAlreadyInUse.rawValue, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                }
            }
            let errorMessage = handleAuthError(error)
            self.errorMessage = errorMessage
            throw error
        }
    }
    
    func resendVerificationEmail() async throws {
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "EmailVerificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured"])
        }
        
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "EmailVerificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let userEmail = user.email ?? "unknown"
            print("📧 Resending verification email to: \(userEmail)")
            
            // Configure ActionCodeSettings with iOS bundle ID (required for iOS)
            let actionCodeSettings = ActionCodeSettings()
            // Use a URL that will redirect to the app
            actionCodeSettings.url = URL(string: "https://alpha-1bd67.firebaseapp.com")
            // Set to false - let it open in browser first, then redirect to app
            // This is more reliable and avoids "operation not valid" errors
            actionCodeSettings.handleCodeInApp = false
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            
            // Send verification email - ONLY call once (calling twice causes rate-limiting)
            try await user.sendEmailVerification(with: actionCodeSettings)
            print("✅ Verification email resent successfully")
            
            lastEmailSentDate = Date()
        } catch {
            print("❌ Error resending verification email: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ Error code: \(nsError.code), domain: \(nsError.domain)")
            }
            let errorMessage = handleAuthError(error)
            self.errorMessage = errorMessage
            throw error
        }
    }
    
    func signIn(email: String, phoneNumber: String) async throws {
        guard FirebaseApp.app() != nil else {
            throw NSError(domain: "EmailVerificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase is not configured"])
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Try to sign in - if account doesn't exist, we'll create it
            // We removed the deprecated fetchSignInMethods check and rely on Firebase's error handling
            // First, check if user is already signed in with this email
            if let currentUser = Auth.auth().currentUser, currentUser.email?.lowercased() == email.lowercased() {
                // User is already signed in with this email - no verification needed
                isEmailVerified = currentUser.isEmailVerified
                print("✅ User already signed in: \(currentUser.uid)")
                return
            }
            
            // Try to send passwordless sign-in link for existing accounts
            // If this succeeds, the account exists. If it fails with userNotFound, we'll create a new account
            // Since we don't have passwords, we use passwordless email link authentication
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://alpha-1bd67.firebaseapp.com")
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            
            do {
                // Try to send sign-in link - if this succeeds, the account exists
                try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
                print("✅ Passwordless sign-in link sent to existing account: \(email)")
                
                // Successfully sent link - inform user to check email
                self.errorMessage = "Sign-in link sent to your email. Please check your inbox (and spam folder) to complete sign-in."
                return // Return successfully after sending link
            } catch let linkError {
                // Check if the error is because the account doesn't exist
                if let linkNsError = linkError as NSError? {
                    let errorCode = AuthErrorCode(_bridgedNSError: linkNsError)
                    if errorCode == .userNotFound {
                        // Account doesn't exist - create new account below
                        print("ℹ️ Account doesn't exist, will create new account")
                    } else {
                        // Other error (too many requests, invalid email, etc.)
                        print("❌ Error sending sign-in link: \(linkError.localizedDescription)")
                        if linkNsError.code == AuthErrorCode.tooManyRequests.rawValue {
                            self.errorMessage = "Too many sign-in attempts. Please wait a moment and try again."
                        } else if linkNsError.code == AuthErrorCode.invalidEmail.rawValue {
                            self.errorMessage = "Invalid email address. Please check and try again."
                        } else {
                            self.errorMessage = "Unable to send sign-in link. Please try again or contact support."
                        }
                        throw linkError
                    }
                } else {
                    // Unknown error - throw it
                    throw linkError
                }
            }
            
            // If we get here, the account doesn't exist, so create it
            // Account doesn't exist - create new account
            // Generate a secure random password for Firebase (not shown to user, used internally)
            let tempPassword = generateSecurePassword()
            
            // Create account
            let result = try await Auth.auth().createUser(withEmail: email, password: tempPassword)
            print("✅ New account created: \(result.user.uid)")
            
            // Sign in the newly created user immediately (no verification needed for new accounts)
            try await Auth.auth().signIn(withEmail: email, password: tempPassword)
            
            // Update user profile if needed
            let changeRequest = result.user.createProfileChangeRequest()
            // You could store phone number in custom claims or user metadata if needed
            try await changeRequest.commitChanges()
            
            isEmailVerified = result.user.isEmailVerified
            print("✅ New account created and signed in: \(result.user.uid)")
        } catch {
            // Handle errors specifically for sign-in (not account creation)
            // Don't show "email already in use" errors during sign-in
            if let nsError = error as NSError? {
                // Note: We no longer use code -2 since we return successfully after sending link
                // This catch block handles other errors
                
                // For Firebase errors during sign-in, provide appropriate messages
                // but never show "email already in use" since that's expected for existing accounts
                switch nsError.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    // This shouldn't happen during sign-in, but if it does, it means account exists
                    // Try to sign in silently or provide helpful message
                    self.errorMessage = "Account found. Please check your email for a sign-in link."
                    throw error
                case AuthErrorCode.invalidEmail.rawValue:
                    self.errorMessage = "Invalid email address. Please check and try again."
                    throw error
                case AuthErrorCode.networkError.rawValue:
                    self.errorMessage = "Network error. Please check your connection and try again."
                    throw error
                case AuthErrorCode.tooManyRequests.rawValue:
                    self.errorMessage = "Too many requests. Please wait a moment and try again."
                    throw error
                case AuthErrorCode.userNotFound.rawValue:
                    self.errorMessage = "No account found with this email. Please create an account first."
                    throw error
                default:
                    // For other errors, provide more specific message based on error description
                    let errorDesc = error.localizedDescription.lowercased()
                    if errorDesc.contains("network") || errorDesc.contains("connection") {
                        self.errorMessage = "Network error. Please check your connection and try again."
                    } else if errorDesc.contains("email") {
                        self.errorMessage = "There was an issue with your email. Please try again."
                    } else {
                        self.errorMessage = "Unable to sign in. Please try again or check your email for a sign-in link."
                    }
                throw error
                }
            } else {
                // For non-NSError errors, use the localized description
                self.errorMessage = error.localizedDescription.isEmpty ? "Unable to sign in. Please try again." : error.localizedDescription
                throw error
            }
        }
    }
    
    private func generateSecurePassword() -> String {
        // Generate a secure random password for internal use only
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        return String((0..<16).map { _ in characters.randomElement()! })
    }

    // Note: Removed emailExists() function because fetchSignInMethods is deprecated
    // We now rely on Firebase's createUser and signIn methods to handle existing accounts
    // Firebase will throw emailAlreadyInUse error if we try to create an account that exists
    
    func handleVerificationLink(url: URL) async {
        guard FirebaseApp.app() != nil else {
            print("⚠️ Firebase not configured")
            return
        }
        
        print("🔗 [EmailVerificationService] Verification link clicked: \(url.absoluteString)")
        
        // Check if this is a sign-in link (passwordless)
        if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
            print("✅ This is a sign-in link (passwordless), not a verification link")
            // Wait a moment for Firebase to process, then check status
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await checkVerificationStatus()
            return
        }
        
        // For email verification links, Firebase may process them automatically
        // We don't need to manually apply the code - just check if verification succeeded
        print("🔗 [EmailVerificationService] Email verification link detected")
        
        // Check if there's a current user
        guard let user = Auth.auth().currentUser else {
            print("⚠️ No user signed in. User may need to sign in first.")
            return
        }
        
        // Wait a moment for Firebase to process the verification (if it processes automatically)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Check verification status - Firebase may have already processed it
        do {
            print("🔄 [EmailVerificationService] Checking verification status...")
            try await user.reload()
            let wasVerified = isEmailVerified
            isEmailVerified = user.isEmailVerified
            
            if isEmailVerified {
                print("✅ [EmailVerificationService] Email is verified!")
                // Post notification so EmailVerificationView can detect it
                if !wasVerified {
                    print("📢 [EmailVerificationService] Email just verified! Posting notification...")
                    NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                }
            } else {
                print("⏳ [EmailVerificationService] Email not yet verified. Will check again...")
                // Check again after another moment
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                try await user.reload()
                isEmailVerified = user.isEmailVerified
                if isEmailVerified {
                    print("✅ [EmailVerificationService] Email verified on second check!")
                    NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                }
            }
        } catch {
            print("❌ [EmailVerificationService] Error checking verification status: \(error.localizedDescription)")
        }
        
        // Final check
        await checkVerificationStatus()
    }
    
    func checkVerificationStatus() async {
        guard FirebaseApp.app() != nil else {
            isEmailVerified = false
            return
        }
        
        // First, check if there's a current user
        if let user = Auth.auth().currentUser {
            // User is signed in - check their verification status
            do {
                print("🔄 [EmailVerificationService] Checking verification status for user: \(user.uid)")
                try await user.reload()
                let wasVerified = isEmailVerified
                isEmailVerified = user.isEmailVerified
                
                if user.isEmailVerified {
                    if !wasVerified {
                        print("✅ [EmailVerificationService] Email verification status changed: User is now verified!")
                        // Post notification immediately when verification is detected
                        print("📢 [EmailVerificationService] Posting notification for verified email...")
                        NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                    } else {
                        print("✅ [EmailVerificationService] User email is verified")
                    }
                } else {
                    print("⏳ [EmailVerificationService] User email is not yet verified")
                }
            } catch {
                print("❌ [EmailVerificationService] Error reloading user: \(error.localizedDescription)")
                // Still check the current status even if reload fails
                let currentStatus = user.isEmailVerified
                if currentStatus != isEmailVerified {
                    isEmailVerified = currentStatus
                    if isEmailVerified {
                        print("✅ [EmailVerificationService] Email is verified (from cached status)")
                        NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationLinkOpened"), object: nil)
                    }
                }
            }
        } else {
            // No user signed in - try to check if we can find a user by email
            // This handles the case where the user verified their email but isn't signed in
            print("⚠️ [EmailVerificationService] No current user found when checking verification status")
            print("💡 [EmailVerificationService] This might mean the user verified their email but isn't signed in")
            print("💡 [EmailVerificationService] The user may need to sign in to complete the process")
            isEmailVerified = false
        }
    }
    
    // New function to check verification status for a specific email
    // This is useful when the user isn't signed in but we know their email
    func checkVerificationStatusForEmail(_ email: String) async -> Bool {
        guard FirebaseApp.app() != nil else {
            return false
        }
        
        // If there's already a signed-in user with this email, check their status
        if let currentUser = Auth.auth().currentUser, 
           currentUser.email?.lowercased() == email.lowercased() {
            do {
                try await currentUser.reload()
                let verified = currentUser.isEmailVerified
                isEmailVerified = verified
                return verified
            } catch {
                print("❌ Error reloading user: \(error.localizedDescription)")
                return currentUser.isEmailVerified
            }
        }
        
        // If no user is signed in, we can't check verification status directly
        // The user needs to sign in first
        print("⚠️ Cannot check verification status: No user signed in with email \(email)")
        return false
    }
    
    func signOut() throws {
        guard FirebaseApp.app() != nil else {
            isEmailVerified = false
            return
        }
        
        try Auth.auth().signOut()
        isEmailVerified = false
    }
    
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as NSError? {
            // Check if it's our custom error message first
            if authError.domain == "EmailVerificationService" && authError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                if let customMessage = authError.userInfo[NSLocalizedDescriptionKey] as? String {
                    return customMessage
                }
            }
            switch authError.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return "This email is already registered. Please sign in instead."
            case AuthErrorCode.weakPassword.rawValue:
                return "Password is too weak. Please use a stronger password."
            case AuthErrorCode.invalidEmail.rawValue:
                return "Invalid email address. Please check and try again."
            case AuthErrorCode.networkError.rawValue:
                return "Network error. Please check your connection and try again."
            case AuthErrorCode.tooManyRequests.rawValue:
                return "Too many requests. Please wait a moment and try again."
            default:
                return "An error occurred. Please try again."
            }
        }
        return error.localizedDescription
    }
}


