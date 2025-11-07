//
//  EmailVerificationView.swift
//  Froth
//
//  Email verification waiting screen
//

import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var store: AppStore
    @ObservedObject var verificationService: EmailVerificationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var resendCooldown = 0
    @State private var showVerifiedSuccess = false
    
    let onVerified: () -> Void
    let userEmail: String
    let userName: String
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let checkVerificationTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Brand.backgroundGradient
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Animated Email Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Brand.primaryBlue.opacity(0.2), Brand.lightCoral.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                        
                        Image(systemName: "envelope.open.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(Brand.primaryBlue)
                            .symbolEffect(.bounce, value: showVerifiedSuccess)
                    }
                    .padding(.top, 60)
                    
                    // Title and Description
                    VStack(spacing: 16) {
                        Text("Check Your Email")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Brand.textPrimary)
                        
                        Text("We've sent a verification link to:")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Brand.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text(userEmail)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Brand.primaryBlue)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    .padding(.horizontal, 24)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionRow(icon: "1.circle.fill", text: "Open your email app")
                        InstructionRow(icon: "2.circle.fill", text: "Find the message from Alpha App Team")
                        InstructionRow(icon: "3.circle.fill", text: "Click the verification link")
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Resend Email Button
                        Button(action: {
                            resendEmail()
                        }) {
                            HStack(spacing: 12) {
                                if verificationService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.9)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(resendCooldown > 0 ? "Wait \(resendCooldown)s" : "Resend Email")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: resendCooldown > 0 ? 
                                        [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] :
                                        [Brand.primaryBlue, Brand.lightCoral],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: resendCooldown > 0 ? Color.clear : Brand.primaryBlue.opacity(0.3),
                                radius: resendCooldown > 0 ? 0 : 12,
                                x: 0,
                                y: 6
                            )
                        }
                        .disabled(verificationService.isLoading || resendCooldown > 0)
                        
                        // Open Email App Button
                        Button(action: {
                            openEmailApp()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Open Email App")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(Brand.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Brand.primaryBlue.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            startResendCooldown()
        }
        .onReceive(timer) { _ in
            updateResendCooldown()
        }
        .onReceive(checkVerificationTimer) { _ in
            Task { @MainActor in
                await checkVerification()
            }
        }
    }
    
    private func startResendCooldown() {
        if let lastSent = verificationService.lastEmailSentDate {
            let elapsed = Date().timeIntervalSince(lastSent)
            resendCooldown = max(0, 60 - Int(elapsed))
        } else {
            resendCooldown = 0
        }
    }
    
    private func updateResendCooldown() {
        if resendCooldown > 0 {
            resendCooldown -= 1
        }
    }
    
    private func resendEmail() {
        guard resendCooldown == 0 else { return }
        
        Task {
            do {
                try await verificationService.resendVerificationEmail()
                resendCooldown = 60
            } catch {
                // Error is already handled in verificationService.errorMessage
            }
        }
    }
    
    private func openEmailApp() {
        if let url = URL(string: "message://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @MainActor
    private func checkVerification() async {
        // Check silently without showing loading overlay
        await verificationService.checkVerificationStatus()
        
        if verificationService.isEmailVerified {
            // Show success animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showVerifiedSuccess = true
            }
            
            // Navigate after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    onVerified()
                }
            }
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Brand.primaryBlue)
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Brand.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}


