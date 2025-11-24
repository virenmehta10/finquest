import SwiftUI
import Combine
import Charts

// MARK: Profile

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var authManager: AuthManager
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showSignOutConfirmation = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                Spacer()
                    .frame(height: 20)
                // Professional Profile Header
                VStack(spacing: 16) {
                    // Avatar with sophisticated styling
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.3, blue: 0.5),
                                        Color(red: 0.1, green: 0.2, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Text(String(store.username.prefix(1)).uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // User info with clean typography
                    VStack(spacing: 4) {
                        Text(store.username)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text("Level \(store.level) • \(store.xp) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Subtle edit button
                    Button(action: { showEditProfile = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .medium))
                            Text("Edit Profile")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                )
                .padding(.horizontal, 20)
                
                // Professional Stats Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Stats")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ProfessionalStatItem(title: "EOY Bonus", value: formatEOYBonus(store.totalPoints), icon: "banknote.fill")
                        ProfessionalStatItem(title: "Level", value: "\(store.level)", icon: "arrow.up.circle.fill")
                        ProfessionalStatItem(title: "Streak", value: "\(store.streakDays)", icon: "flame.fill")
                        ProfessionalStatItem(title: "Perfect", value: "\(store.perfectLessons)", icon: "checkmark.seal.fill")
                        ProfessionalStatItem(title: "Lessons", value: "\(store.completedLessonIDs.count)", icon: "book.fill")
                        ProfessionalStatItem(title: "Study Time", value: "\(store.totalStudyTime)m", icon: "clock.fill")
                    }
                    .padding(.horizontal, 20)
                }
                
                // Clean Settings Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        ProfessionalSettingsRow(
                            title: "Notifications",
                            icon: "bell.fill",
                            isOn: $store.notificationsEnabled
                        )
                        
                        ProfessionalSettingsRow(
                            title: "Sound Effects",
                            icon: "speaker.wave.2.fill",
                            isOn: $store.soundEnabled
                        )
                        
                        ProfessionalSettingsRow(
                            title: "Haptic Feedback",
                            icon: "iphone.radiowaves.left.and.right",
                            isOn: $store.hapticsEnabled
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Sign Out Section
                VStack(spacing: 12) {
                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .font(.system(size: 18, weight: .medium))
                            Text("Sign Out")
                                .font(.body.weight(.semibold))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? You'll need to sign in again to access your account.")
        }
    }
    
    private func signOut() {
        authManager.signOut()
        // The ContentView will automatically detect the sign out and show onboarding
    }
    
    private func formatEOYBonus(_ points: Double) -> String {
        if points.truncatingRemainder(dividingBy: 1) == 0 {
            return "$\(Int(points))K"
        } else {
            return String(format: "$%.1fK", points)
        }
    }
}

struct ProfessionalStatItem: View {
    let title: String
    let value: String
    let icon: String
    @State private var appear = false
    
    private var iconColor: Color {
        switch icon {
        case "banknote.fill":
            return Color(red: 0.2, green: 0.6, blue: 0.3) // Money green
        case "star.fill":
            return Color(red: 0.8, green: 0.7, blue: 0.2) // Dull yellow
        case "arrow.up.circle.fill":
            return Color(red: 0.3, green: 0.5, blue: 0.8) // Dull blue
        case "flame.fill":
            return Color(red: 0.8, green: 0.4, blue: 0.2) // Dull orange
        case "checkmark.seal.fill":
            return Color(red: 0.3, green: 0.7, blue: 0.3) // Dull green
        case "book.fill":
            return Color(red: 0.6, green: 0.4, blue: 0.8) // Dull purple
        case "clock.fill":
            return Color(red: 0.4, green: 0.6, blue: 0.7) // Dull teal
        default:
            return .primary
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
                Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)
                
                Text(value)
                .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text(title)
                .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(appear ? 1 : 0.9)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct ProfessionalSettingsRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    @State private var appear = false
    
    var body: some View {
            HStack(spacing: 16) {
                    Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
                
                Text(title)
                .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(appear ? 1 : 0.95)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.2)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Edit Profile")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text("Update your account information")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Profile fields
                    VStack(spacing: 20) {
                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            
                            Text("This will be shown on your profile and leaderboard")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Phone number field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter phone number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            
                            Text("We'll use this to verify your account")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            
                            Text("We'll send you updates about your progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Save button
                    Button("Save Changes") {
                        saveProfile()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(isLoading || username.isEmpty)
                    .opacity(isLoading || username.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Load current values
            username = store.username
            phoneNumber = store.phoneNumber
            email = store.email
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Simulate save delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Update store with new values
            store.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            store.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            store.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
            
            isLoading = false
            dismiss()
        }
    }
}

// NOTE: Older simple SettingsView removed to avoid redeclaration. A modern version exists below.

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

struct ProgressBar: View {
    let title: String
    let current: Int
    let total: Int
    let color: Color
    
    var progress: Double {
        min(1.0, Double(current) / Double(total))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(current)/\(total)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(Color.mint)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Removed duplicate EditNameView to avoid redeclaration error

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle.weight(.bold))
                    .padding()
                
                Spacer()
                
                Text("Settings panel coming soon!")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview (commented out to prevent interference with app)

/*
#Preview("ContentView") {
    let previewStore = AppStore()
    previewStore.isPreviewMode = true
    return ContentView()
        .environmentObject(previewStore)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let previewStore = AppStore()
    previewStore.isPreviewMode = true
    return ContentView()
        .environmentObject(previewStore)
        .preferredColorScheme(.dark)
}
*/



