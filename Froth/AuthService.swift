//
//  AuthService.swift
//  Froth
//
//  Created by Assistant on 1/15/25.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isEmailVerified = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                self?.isEmailVerified = user?.isEmailVerified ?? false
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let user = result?.user, error == nil {
                    user.sendEmailVerification { error in
                        if let error = error {
                            self?.errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                        }
                    }
                }
                completion(error)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let user = result?.user, error == nil else {
                    completion(false, error)
                    return
                }
                
                user.reload { _ in
                    DispatchQueue.main.async {
                        completion(user.isEmailVerified, nil)
                    }
                }
            }
        }
    }
    
    func resendVerification(completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"]))
            return
        }
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to resend verification email: \(error.localizedDescription)"
                }
                completion(error)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.isEmailVerified = false
                self.currentUser = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
            }
        }
    }
    
    func refreshUser() {
        Auth.auth().currentUser?.reload { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to refresh user: \(error.localizedDescription)"
                } else {
                    self?.isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
                }
            }
        }
    }
}

