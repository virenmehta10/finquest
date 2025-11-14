//
//  EmailVerificationView.swift
//  Froth
//
//  Email verification waiting screen
//

import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @EnvironmentObject var store: AppStore
    @ObservedObject var verificationService: EmailVerificationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var resendCooldown = 0
    @State private var showVerifiedSuccess = false
    @State private var showStatusAlert = false
    @State private var statusMessage = ""
    @State private var isCheckingVerification = false
    
    let onVerified: () -> Void
    let userEmail: String
    let userName: String
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let checkVerificationTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect() // Check every 2 seconds
    
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
                        InstructionRow(icon: "1.circle.fill", text: "Open your email (on phone or computer)")
                        InstructionRow(icon: "2.circle.fill", text: "Find the message from Alpha App Team")
                        InstructionRow(icon: "3.circle.fill", text: "Click the verification link in the email")
                        InstructionRow(icon: "4.circle.fill", text: "Wait for 'Email successfully verified' message")
                        InstructionRow(icon: "5.circle.fill", text: "Press 'I've Verified My Email' button below")
                        
                        // Show message if user is not signed in
                        if Auth.auth().currentUser == nil {
                            InstructionRow(
                                icon: "exclamationmark.triangle.fill",
                                text: "After verifying, you may need to sign in to complete the process"
                            )
                            .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 20)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        // Check Verification Status Button (NEW - for manual checking)
                        Button(action: {
                            checkVerificationManually()
                        }) {
                            HStack(spacing: 12) {
                                if isCheckingVerification || verificationService.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.9)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Checking...")
                                        .font(.system(size: 17, weight: .semibold))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("I've Verified My Email")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: isCheckingVerification ? 
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.4)] :
                                        [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: isCheckingVerification ? Color.clear : Color.green.opacity(0.3),
                                radius: isCheckingVerification ? 0 : 12,
                                x: 0,
                                y: 6
                            )
                        }
                        .disabled(verificationService.isLoading || isCheckingVerification)
                        
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Verification Status", isPresented: $showStatusAlert) {
            Button("OK", role: .cancel) { }
            // Always show option to proceed anyway
            Button("I Verified It - Proceed Anyway") {
                // User confirms they verified, proceed to app
                print("⚠️ [EmailVerificationView] User confirmed verification - proceeding anyway")
                verificationService.isEmailVerified = true
                onVerified()
            }
        } message: {
            Text(statusMessage)
        }
        .onAppear {
            startResendCooldown()
            // Check verification status immediately when view appears
            Task { @MainActor in
                await checkVerification()
            }
        }
        .onReceive(timer) { _ in
            updateResendCooldown()
        }
        .onReceive(checkVerificationTimer) { _ in
            Task { @MainActor in
                await checkVerification()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Check verification status when app becomes active (user returns from email or link opens app)
            Task { @MainActor in
                print("📱 [EmailVerificationView] App became active - checking verification status immediately...")
                // Check immediately - no delay
                await checkVerification()
                // Check multiple times with short delays to catch verification
                for i in 1...5 {
                    try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
                    print("🔄 [EmailVerificationView] Re-checking verification (attempt \(i))...")
                    await checkVerification()
                    
                    // If verified, we can stop checking
                    if verificationService.isEmailVerified {
                        print("✅ [EmailVerificationView] Verification detected! Stopping checks.")
                        break
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EmailVerificationLinkOpened"))) { _ in
            // Check verification status when verification link is opened
            // This is triggered when the app opens from the verification link
            Task { @MainActor in
                print("🔔 [EmailVerificationView] Received EmailVerificationLinkOpened notification")
                // Check immediately - no delay needed
                await checkVerification()
                // Check again after a short delay to ensure Firebase has processed it
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await checkVerification()
                // Check one more time after another short delay
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
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
    
    private func checkVerificationManually() {
        isCheckingVerification = true
        statusMessage = "Checking verification status..."
        showStatusAlert = true
        
        print("🔘 [EmailVerificationView] ===== USER TAPPED 'I've Verified My Email' BUTTON =====")
        Task { @MainActor in
            // First, make sure user is signed in (they should be after account creation)
            guard let user = Auth.auth().currentUser else {
                let errorMsg = "ERROR: No user signed in!\n\nYou should be signed in after creating your account. Please try creating your account again."
                statusMessage = errorMsg
                showStatusAlert = true
                isCheckingVerification = false
                print("❌ [EmailVerificationView] ERROR: No user signed in!")
                return
            }
            
            let userEmail = user.email ?? "unknown"
            print("✅ [EmailVerificationView] User IS signed in!")
            print("   - User UID: \(user.uid)")
            print("   - User email: \(userEmail)")
            print("   - Email shown on screen: \(self.userEmail)")
            print("   - Emails match: \(userEmail.lowercased() == self.userEmail.lowercased())")
            print("   - Current verified status (cached): \(user.isEmailVerified)")
            print("   - User metadata: \(user.metadata)")
            
            // Check if emails match
            if userEmail.lowercased() != self.userEmail.lowercased() {
                let errorMsg = "EMAIL MISMATCH!\n\nSigned in email: \(userEmail)\nExpected email: \(self.userEmail)\n\nThese don't match! Please verify the correct email."
                statusMessage = errorMsg
                showStatusAlert = true
                isCheckingVerification = false
                return
            }
            
            statusMessage = "User signed in: \(userEmail)\nChecking verification status..."
            
            // Force reload user multiple times to ensure we get latest status from Firebase
            for attempt in 1...5 {
                statusMessage = "Checking verification... (Attempt \(attempt)/5)"
                print("\n🔄 [EmailVerificationView] === Verification Check Attempt \(attempt) ===")
                
                do {
                    // Reload user to get latest status from Firebase server
                    print("   📡 Reloading user from Firebase...")
                    try await user.reload()
                    print("   ✅ User reloaded successfully")
                    print("   📧 Verified status from Firebase: \(user.isEmailVerified)")
                    print("   📧 User email: \(user.email ?? "unknown")")
                    print("   📧 User display name: \(user.displayName ?? "none")")
                    print("   📧 User creation date: \(user.metadata.creationDate)")
                    print("   📧 Last sign in: \(user.metadata.lastSignInDate)")
                    
                    // Also update service status
                    await verificationService.checkVerificationStatus()
                    print("   📧 Verified status from service: \(verificationService.isEmailVerified)")
                    
                    // DEBUG: Check Firebase directly
                    print("   🔍 DEBUG: Checking Firebase user object directly...")
                    print("   🔍 user.isEmailVerified = \(user.isEmailVerified)")
                    print("   🔍 user.email = \(user.email ?? "nil")")
                    
                    // Check if verified - use OR to catch either source
                    let isVerified = user.isEmailVerified || verificationService.isEmailVerified
                    
                    if isVerified {
                        print("\n✅✅✅ [EmailVerificationView] EMAIL IS VERIFIED! ✅✅✅")
                        print("   Proceeding to main app...")
                        
                        // Update service status to be sure
                        verificationService.isEmailVerified = true
                        isCheckingVerification = false
                        
                        // Show success message briefly
                        statusMessage = "✅ Email verified successfully!\n\nTaking you to the app..."
                        showStatusAlert = true
                        
                        // Wait a moment for user to see the message
                        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        
                        // Call the callback to proceed
                        onVerified()
                        return // Exit early - we're done!
                    } else {
                        print("   ⏳ Email not verified yet (attempt \(attempt)/5)")
                        statusMessage = "Email not verified yet (Attempt \(attempt)/5)\n\nMake sure you clicked the verification link in your email."
                    }
                } catch {
                    print("   ❌ Error on attempt \(attempt): \(error.localizedDescription)")
                    statusMessage = "Error checking verification: \(error.localizedDescription)"
                    
                    // Still check cached status
                    if user.isEmailVerified {
                        print("   ✅ But cached status shows verified! Proceeding...")
                        verificationService.isEmailVerified = true
                        isCheckingVerification = false
                        statusMessage = "✅ Email verified! Taking you to the app..."
                        showStatusAlert = true
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        onVerified()
                        return
                    }
                }
                
                // Wait before next attempt (except on last attempt)
                if attempt < 5 {
                    print("   ⏱️ Waiting 0.5 seconds before next check...")
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                }
            }
            
            // If we get here, verification failed
            isCheckingVerification = false
            
            // Final check - maybe Firebase just needs more time
            print("   🔄 Final check - reloading one more time...")
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            try? await user.reload()
            
            if user.isEmailVerified {
                print("   ✅ FINAL CHECK: Email IS verified!")
                verificationService.isEmailVerified = true
                statusMessage = "✅ Email verified! Taking you to the app..."
                showStatusAlert = true
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                onVerified()
                return
            }
            
            // Show detailed error message with option to proceed anyway
            let finalMsg = """
            Email verification not found in Firebase.
            
            Current status:
            • User email: \(user.email ?? "unknown")
            • Verified in Firebase: NO
            • User UID: \(user.uid)
            
            The verification link must be clicked and processed.
            
            To verify:
            1. Open the email sent to: \(user.email ?? "unknown")
            2. Click the verification link
            3. Wait for "Email successfully verified" message
            4. Come back and press this button again
            
            Or use "I Verified It - Proceed Anyway" if you're sure it's verified.
            """
            statusMessage = finalMsg
            showStatusAlert = true
            
            print("\n⚠️ [EmailVerificationView] Verification check completed but email still not verified")
        }
    }
    
    @MainActor
    private func checkVerification() async {
        // Check silently without showing loading overlay
        print("🔍 [EmailVerificationView] Checking verification status...")
        
        // First check if there's a signed-in user
        guard let user = Auth.auth().currentUser else {
            print("⚠️ [EmailVerificationView] No user signed in. Email may be verified but user needs to sign in.")
            print("💡 [EmailVerificationView] User should use the sign-in flow to complete the process.")
            // Don't proceed - user needs to sign in first
            return
        }
        
        print("✅ [EmailVerificationView] User is signed in: \(user.uid), email: \(user.email ?? "unknown")")
        
        // Force reload the user to get the latest verification status from Firebase
        do {
            print("🔄 [EmailVerificationView] Reloading user to get latest status from Firebase...")
            try await user.reload()
            print("📧 [EmailVerificationView] User reloaded. Verified status: \(user.isEmailVerified)")
        } catch {
            print("⚠️ [EmailVerificationView] Error reloading user: \(error.localizedDescription)")
            // Still try to check cached status
            print("📧 [EmailVerificationView] Using cached status: \(user.isEmailVerified)")
        }
        
        // Now check verification status through the service
        await verificationService.checkVerificationStatus()
        
        print("📧 [EmailVerificationView] Verification status from service: \(verificationService.isEmailVerified)")
        print("📧 [EmailVerificationView] Verification status from user: \(user.isEmailVerified)")
        
        // Double-check directly from user object - use OR to catch either source
        let isVerified = user.isEmailVerified || verificationService.isEmailVerified
        
        if isVerified {
            print("✅ [EmailVerificationView] Email verified! Automatically navigating to home...")
            // Update service status if needed
            if !verificationService.isEmailVerified {
                verificationService.isEmailVerified = true
            }
            
            // Show success animation briefly
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showVerifiedSuccess = true
            }
            
            // Automatically navigate immediately - no user interaction needed
            // Small delay just for visual feedback, then auto-dismiss
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds for visual feedback
            onVerified()
        } else {
            print("⏳ [EmailVerificationView] Email not yet verified. Will check again...")
            print("💡 [EmailVerificationView] Make sure you're signed in and the email is verified in Firebase")
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


