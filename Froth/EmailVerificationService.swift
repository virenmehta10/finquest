//
//  EmailVerificationService.swift
//  Froth
//
//  Email verification service using Firebase Authentication
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class EmailVerificationService: ObservableObject {
    @Published var isEmailVerified = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastEmailSentDate: Date?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Task { @MainActor in
                self?.isEmailVerified = user?.isEmailVerified ?? false
            }
        }
    }
    
    func createAccount(email: String, password: String, username: String) async throws -> String {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Create Firebase user account
            print("🔵 Creating Firebase account for: \(email)")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
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
            }
            let errorMessage = handleAuthError(error)
            self.errorMessage = errorMessage
            throw error
        }
    }
    
    func resendVerificationEmail() async throws {
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
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        } catch {
            let errorMessage = handleAuthError(error)
            self.errorMessage = errorMessage
            throw error
        }
    }

    // Check if an email has any sign-in method (i.e., is registered)
    func emailExists(_ email: String) async -> Bool {
        do {
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            return !methods.isEmpty
        } catch {
            return false
        }
    }
    
    func checkVerificationStatus() async {
        guard let user = Auth.auth().currentUser else {
            isEmailVerified = false
            return
        }
        
        // Reload user to get latest email verification status
        do {
            try await user.reload()
            isEmailVerified = user.isEmailVerified
        } catch {
            print("Error reloading user: \(error.localizedDescription)")
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        isEmailVerified = false
    }
    
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return "This email is already registered. Please use a different email."
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

