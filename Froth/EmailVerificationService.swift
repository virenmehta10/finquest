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
            setupAuthStateListener()
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
            // Check if email already exists BEFORE trying to create account
            // Note: This is a pre-check, but Firebase's createUser will be the authoritative check
            let accountExists = await emailExists(email)
            if accountExists {
                // Pre-check says email exists, but we'll still try to create and let Firebase confirm
                print("⚠️ Pre-check indicates email \(email) might exist, but proceeding to let Firebase confirm")
            }
            
            // Create Firebase user account
            // Firebase will throw emailAlreadyInUse if the email actually exists
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
            actionCodeSettings.url = URL(string: "https://alpha-1bd67.firebaseapp.com")
            actionCodeSettings.handleCodeInApp = false  // Open in browser - it will process verification, then we check status when app becomes active
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
            actionCodeSettings.url = URL(string: "https://alpha-1bd67.firebaseapp.com")
            actionCodeSettings.handleCodeInApp = false  // Open in browser - it will process verification, then we check status when app becomes active
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
            // Check if email exists (account already exists)
            let accountExists = await emailExists(email)
            
            if accountExists {
                // For existing accounts, check if user is already signed in (persistent session)
                if let currentUser = Auth.auth().currentUser, currentUser.email?.lowercased() == email.lowercased() {
                    // User is already signed in with this email - no verification needed
                    isEmailVerified = currentUser.isEmailVerified
                    print("✅ User already signed in: \(currentUser.uid)")
                    return
                }
                
                // For existing accounts without active session:
                // Since passwords don't exist, we need to use passwordless email link authentication
                // However, Firebase requires the user to click the link to complete sign-in
                // This is a limitation without a backend service that can issue custom tokens
                
                // Try to send passwordless sign-in link
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://alpha-1bd67.firebaseapp.com")
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            
                do {
            try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
                    print("✅ Passwordless sign-in link sent to existing account: \(email)")
                    
                    // Successfully sent link - inform user to check email
                    // Don't throw error, just set message and return
                    self.errorMessage = "Sign-in link sent to your email. Please check your inbox (and spam folder) to complete sign-in."
                    
                    // Note: The user will need to click the link in their email to complete sign-in
                    // This is a Firebase requirement for passwordless authentication
                    // For true no-verification sign-in, implement a backend service that:
                    // 1. Validates email + phone number
                    // 2. Uses Firebase Admin SDK to generate custom tokens
                    // 3. Signs the user in with the custom token
                    
                    return // Return successfully after sending link
                } catch let linkError {
                    // If sending link fails, provide helpful error message
                    print("❌ Error sending sign-in link: \(linkError.localizedDescription)")
                    if let linkNsError = linkError as NSError? {
                        if linkNsError.code == AuthErrorCode.tooManyRequests.rawValue {
                            self.errorMessage = "Too many sign-in attempts. Please wait a moment and try again."
                        } else if linkNsError.code == AuthErrorCode.invalidEmail.rawValue {
                            self.errorMessage = "Invalid email address. Please check and try again."
                        } else {
                            self.errorMessage = "Unable to send sign-in link. Please try again or contact support."
                        }
                    } else {
                        self.errorMessage = "Unable to complete sign-in. Please try again."
                    }
                    throw linkError
                }
            } else {
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
            }
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

    // Check if an email has any sign-in method (i.e., is registered)
    func emailExists(_ email: String) async -> Bool {
        guard FirebaseApp.app() != nil else {
            print("⚠️ Firebase not configured - cannot check if email exists")
            return false
        }
        
        do {
            print("🔍 Checking if email exists: \(email)")
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            let exists = !methods.isEmpty
            if exists {
                print("✅ Email \(email) exists with methods: \(methods)")
            } else {
                print("❌ Email \(email) does NOT exist in Firebase (no sign-in methods found)")
            }
            return exists
        } catch {
            // If fetchSignInMethods throws an error, it usually means the email doesn't exist
            // Firebase throws specific errors for non-existent emails
            if let nsError = error as NSError? {
                let errorCode = AuthErrorCode(_bridgedNSError: nsError)
                // userNotFound means email doesn't exist - this is expected
                if errorCode == .userNotFound {
                    print("❌ Email \(email) does NOT exist in Firebase (userNotFound error)")
                    return false
                }
                // invalidEmail means the email format is wrong
                if errorCode == .invalidEmail {
                    print("⚠️ Invalid email format: \(email)")
                    return false
                }
                // For other errors, log them but assume email doesn't exist to be safe
                print("⚠️ Error checking if email exists: \(error.localizedDescription) (code: \(nsError.code))")
            } else {
                print("⚠️ Unknown error checking if email exists: \(error.localizedDescription)")
            }
            // Return false on error to allow account creation to proceed
            // Firebase will catch it if the email actually exists
            return false
        }
    }
    
    func handleVerificationLink(url: URL) async {
        guard FirebaseApp.app() != nil else {
            print("⚠️ Firebase not configured")
            return
        }
        
        print("🔗 Handling verification link: \(url.absoluteString)")
        
        // Check if this is a sign-in link first
        if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
            print("✅ This is a sign-in link (passwordless), not a verification link")
            // Don't process sign-in links here
            return
        }
        
        // When the verification link is clicked, it may:
        // 1. Open in browser first, which processes it, then redirects to app
        // 2. Open directly in app (if handleCodeInApp = true)
        // In either case, the verification may have already been processed.
        // We should NOT try to apply the action code again, as it will fail with "operation not valid"
        // Instead, just check if the email is already verified.
        
        print("🔗 Verification link opened. Checking verification status (not applying code)...")
        
        // Wait a moment for Firebase to process if it was just clicked
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Just check verification status - don't try to apply the code
        await checkVerificationStatus()
        
        // Check again after another moment to be sure
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        await checkVerificationStatus()
    }
    
    func checkVerificationStatus() async {
        guard FirebaseApp.app() != nil else {
            isEmailVerified = false
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            isEmailVerified = false
            print("⚠️ No current user found when checking verification status")
            return
        }
        
        // Reload user to get latest email verification status from Firebase
        do {
            print("🔄 Checking verification status for user: \(user.uid)")
            try await user.reload()
            let wasVerified = isEmailVerified
            isEmailVerified = user.isEmailVerified
            
            if user.isEmailVerified && !wasVerified {
                print("✅ Email verification status changed: User is now verified!")
            } else if user.isEmailVerified {
                print("✅ User email is verified")
            } else {
                print("⏳ User email is not yet verified")
            }
        } catch {
            print("❌ Error reloading user: \(error.localizedDescription)")
            // Still check the current status even if reload fails
            isEmailVerified = user.isEmailVerified
        }
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

