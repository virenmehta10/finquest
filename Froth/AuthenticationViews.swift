//
//  AuthenticationViews.swift
//  Froth
//
//  Created by Assistant on 1/15/25.
//

import SwiftUI
import FirebaseAuth

// MARK: - Authentication Views

struct AuthenticationView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            if showingSignUp {
                SignUpView(authService: authService, showingSignUp: $showingSignUp)
            } else {
                SignInView(authService: authService, showingSignUp: $showingSignUp)
            }
        }
    }
}

struct SignInView: View {
    @ObservedObject var authService: AuthService
    @Binding var showingSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackgroundWithSplashes()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)
                    
                    // Logo/Title
                    VStack(spacing: 16) {
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Sign in to continue your learning journey")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign In Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(SoftTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(SoftTextFieldStyle())
                        }
                        
                        // Sign In Button
                        Button(action: signIn) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                        
                        // Error Message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button("Sign Up") {
                            showingSignUp = true
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .alert("Sign In Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func signIn() {
        authService.signIn(email: email, password: password) { isVerified, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
            } else if !isVerified {
                // User is signed in but email not verified
                // This will be handled by the main app's authentication state
            }
        }
    }
}

struct SignUpView: View {
    @ObservedObject var authService: AuthService
    @Binding var showingSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingVerification = false
    
    var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackgroundWithSplashes()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 50)
                    
                    // Logo/Title
                    VStack(spacing: 16) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Join Froth and start your learning journey")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign Up Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(SoftTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(SoftTextFieldStyle())
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(SoftTextFieldStyle())
                        }
                        
                        // Sign Up Button
                        Button(action: signUp) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword)
                        
                        // Error Message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Sign In Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button("Sign In") {
                            showingSignUp = false
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .alert("Sign Up Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingVerification) {
            EmailVerificationView(authService: authService)
        }
    }
    
    private func signUp() {
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters"
            showingAlert = true
            return
        }
        
        authService.signUp(email: email, password: password) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
            } else {
                showingVerification = true
            }
        }
    }
}

struct EmailVerificationView: View {
    @ObservedObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                AnimatedGradientBackgroundWithSplashes()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    // Title
                    Text("Check Your Email")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("We've sent a verification link to your email address.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("Please check your inbox and click the verification link to activate your account.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Resend Email Button
                        Button(action: resendVerification) {
                            HStack {
                                Text("Resend Verification Email")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authService.isLoading)
                        
                        // Check Verification Button
                        Button(action: checkVerification) {
                            HStack {
                                Text("I've Verified My Email")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Sign Out Button (for testing)
                        Button(action: signOut) {
                            HStack {
                                Text("Sign Out & Use Different Email")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationTitle("Email Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Verification", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func resendVerification() {
        authService.resendVerification { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Verification email sent successfully!"
            }
            showingAlert = true
        }
    }
    
    private func checkVerification() {
        authService.refreshUser()
        
        if authService.isEmailVerified {
            alertMessage = "Email verified successfully! You can now use the app."
            showingAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }
        } else {
            alertMessage = "Email not yet verified. Please check your inbox and click the verification link."
            showingAlert = true
        }
    }
    
    private func signOut() {
        authService.signOut()
    }
}

// MARK: - Custom Text Field Style

struct SoftTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

