import SwiftUI
import Combine
import Charts

// MARK: Profile

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showEditProfile = false
    @State private var showSettings = false

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
            ScrollView {
                    LazyVStack(spacing: 24) {
                        // Profile header with glassmorphism
                        GlassmorphismCard(cornerRadius: 24, shadowRadius: 15) {
                    VStack(spacing: 20) {
                        // Avatar and name
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                                    colors: [Color.mint, .blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                            .frame(width: min(100, geometry.size.width * 0.25), height: min(100, geometry.size.width * 0.25))
                                            .shadow(color: Color.mint.opacity(0.3), radius: 12, x: 0, y: 6)
                                
                                Text(String(store.username.prefix(1)).uppercased())
                                            .font(.system(size: min(40, geometry.size.width * 0.1), weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text(store.username)
                                            .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Level \(store.level) • \(store.xp) XP")
                                            .font(.system(size: min(16, geometry.size.width * 0.04)))
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: { showEditProfile = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                        .font(.system(size: min(14, geometry.size.width * 0.035), weight: .medium))
                                .foregroundColor(Color.mint)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.mint.opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                                .padding(min(20, geometry.size.width * 0.05))
                            }
                    .padding(.horizontal, 20)
                            .padding(.top, 20)
                    
                            // Stats grid with modern cards
                    VStack(alignment: .leading, spacing: 16) {
                                Text("Your Stats")
                                    .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                            .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                        LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                                    ModernStatItem(title: "Total XP", value: "\(store.xp)", icon: "star.fill", color: .yellow, geometry: geometry)
                                    ModernStatItem(title: "Level", value: "\(store.level)", icon: "arrow.up.circle.fill", color: .blue, geometry: geometry)
                                    ModernStatItem(title: "Streak", value: "\(store.streakDays)", icon: "flame.fill", color: .orange, geometry: geometry)
                                    ModernStatItem(title: "Perfect", value: "\(store.perfectLessons)", icon: "checkmark.seal.fill", color: .green, geometry: geometry)
                                    ModernStatItem(title: "Lessons", value: "\(store.completedLessonIDs.count)", icon: "book.fill", color: .purple, geometry: geometry)
                                    ModernStatItem(title: "Study Time", value: "\(store.totalStudyTime)m", icon: "clock.fill", color: Color.mint, geometry: geometry)
                                }
                    .padding(.horizontal, 20)
                            }
                    
                    // Settings section
                    VStack(alignment: .leading, spacing: 16) {
                                Text("Settings")
                                    .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                            .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                                    ModernSettingsRow(
                            title: "Notifications",
                                        icon: "bell.fill",
                                        color: .blue,
                                        isOn: $store.notificationsEnabled,
                                        geometry: geometry
                                    )
                                    
                                    ModernSettingsRow(
                                        title: "Sound Effects",
                            icon: "speaker.wave.2.fill",
                                        color: .green,
                                        isOn: $store.soundEnabled,
                                        geometry: geometry
                                    )
                                    
                                    ModernSettingsRow(
                                        title: "Haptic Feedback",
                                        icon: "iphone.radiowaves.left.and.right",
                                        color: .purple,
                                        isOn: $store.hapticsEnabled,
                                        geometry: geometry
                                    )
                                }
                    .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 100)
                        }
                    }
                    .background(
                        AnimatedGradientBackground(
                            colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.08), Color.mint.opacity(0.06), Color.cyan.opacity(0.04)]
                        )
                    )
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        
        // Add missing components
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct ModernStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 16, shadowRadius: 8) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: min(16, geometry.size.width * 0.04), weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: min(12, geometry.size.width * 0.03), weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(min(12, geometry.size.width * 0.03))
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct ModernSettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 16, shadowRadius: 8) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                LinearGradient(
                                colors: [color.opacity(0.8), color],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
                        .frame(width: min(40, geometry.size.width * 0.1), height: min(40, geometry.size.width * 0.1))
                    
                    Image(systemName: icon)
                        .font(.system(size: min(18, geometry.size.width * 0.045), weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: min(16, geometry.size.width * 0.04), weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: color))
            }
            .padding(min(16, geometry.size.width * 0.04))
        }
        .scaleEffect(appear ? 1 : 0.8)
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

// MARK: - Preview

#Preview("ContentView") {
    ContentView()
        .environmentObject(AppStore())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .environmentObject(AppStore())
        .preferredColorScheme(.dark)
}



