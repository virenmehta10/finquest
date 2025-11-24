import FirebaseAuth
import Foundation

class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isEmailVerified: Bool = false
    
    init() {
        self.currentUser = Auth.auth().currentUser
        self.isEmailVerified = currentUser?.isEmailVerified ?? false
        
        // Listen for auth state changes (e.g., when user verifies email)
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isEmailVerified = user?.isEmailVerified ?? false
            }
        }
    }
    
    // Sign up new user with email verification
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Send verification email
            authResult?.user.sendEmailVerification { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Keep user signed in but mark as unverified
                // They can verify via email link and we'll check status
                self?.currentUser = authResult?.user
                self?.isEmailVerified = false
                completion(.success(()))
            }
        }
    }
    
    // Sign in existing user
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            // Check if email is verified
            if user.isEmailVerified {
                self?.currentUser = user
                self?.isEmailVerified = true
                completion(.success(()))
            } else {
                // Sign out if not verified
                try? Auth.auth().signOut()
                self?.currentUser = nil
                self?.isEmailVerified = false
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please verify your email before signing in"])))
            }
        }
    }
    
    // Resend verification email
    func resendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        
        user.sendEmailVerification { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    // Sign out
    func signOut() {
        try? Auth.auth().signOut()
        self.currentUser = nil
        self.isEmailVerified = false
    }
    
    // Refresh user to check verification status
    func refreshUser(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload { [weak self] error in
            if error == nil {
                self?.isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
                completion(self?.isEmailVerified ?? false)
            } else {
                completion(false)
            }
        }
    }
}

