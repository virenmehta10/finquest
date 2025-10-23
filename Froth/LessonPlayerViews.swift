import SwiftUI
import Combine
import Charts

// MARK: Leaderboard (mocked)

// MARK: - Pro Upgrade View

struct ProUpgradeView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKitManager = StoreKitManager()
    @State private var animateElements = false
    @State private var showPurchaseAnimation = false
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Stunning gradient background
                LinearGradient(
                    colors: [Brand.lightBlue.opacity(0.3), Brand.primaryBlue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Hero Section
                        VStack(spacing: 20) {
                            // Crown icon with animation
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
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(animateElements ? 1.0 : 0.8)
                                    .opacity(animateElements ? 1.0 : 0.0)
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .scaleEffect(animateElements ? 1.0 : 0.8)
                                    .opacity(animateElements ? 1.0 : 0.0)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Unlock Your Full Potential")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .scaleEffect(animateElements ? 1.0 : 0.9)
                                    .opacity(animateElements ? 1.0 : 0.0)
                                
                                Text("Join thousands of students mastering finance technicals")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .scaleEffect(animateElements ? 1.0 : 0.9)
                                    .opacity(animateElements ? 1.0 : 0.0)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Pricing Card
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
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
                                    .frame(height: 120)
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text("$20")
                                                .font(.system(size: 36, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("/ year")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Text("Best Value")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.green, lineWidth: 1.5)
                                            )
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white.opacity(0.1))
                                            )
                                        Spacer()
                                    }
                                }
                            }
                            .scaleEffect(animateElements ? 1.0 : 0.95)
                            .opacity(animateElements ? 1.0 : 0.0)
                        }
                        
                        // Features Grid
                        VStack(spacing: 16) {
                            Text("What's Included")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .scaleEffect(animateElements ? 1.0 : 0.9)
                                .opacity(animateElements ? 1.0 : 0.0)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                FeatureCard(
                                    icon: "chart.bar.doc.horizontal",
                                    title: "All Modules",
                                    description: "Access all 5 premium modules",
                                    delay: 0.1,
                                    iconColor: Color.blue
                                )
                                
                                FeatureCard(
                                    icon: "lock.open.fill",
                                    title: "20+ Levels",
                                    description: "Unlock all premium content",
                                    delay: 0.2,
                                    iconColor: Color.purple.opacity(0.8)
                                )
                            }
                        }
                        
                        // Purchase Button
                        VStack(spacing: 16) {
                            Button(action: {
                                Task {
                                    await purchasePro()
                                }
                            }) {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "applelogo")
                                            .font(.system(size: 18, weight: .medium))
                                        Text("Purchase with Apple Pay")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.3, blue: 0.5),
                                            Color(red: 0.1, green: 0.2, blue: 0.4)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .disabled(isPurchasing)
                            .scaleEffect(animateElements ? 1.0 : 0.95)
                            .opacity(animateElements ? 1.0 : 0.0)
                            
                            Button("Restore Purchases") {
                                Task {
                                    await restorePurchases()
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .scaleEffect(animateElements ? 1.0 : 0.95)
                            .opacity(animateElements ? 1.0 : 0.0)
                        }
                        
                        // Trust indicators
                        VStack(spacing: 12) {
                            HStack(spacing: 20) {
                                TrustIndicator(icon: "checkmark.shield.fill", text: "Secure", iconColor: Brand.gold)
                                TrustIndicator(icon: "arrow.clockwise", text: "Cancel Anytime", iconColor: .green)
                                TrustIndicator(icon: "heart.fill", text: "Loved by 10k+", iconColor: Color(red: 1.0, green: 0.4, blue: 0.4))
                            }
                        }
                        .scaleEffect(animateElements ? 1.0 : 0.9)
                        .opacity(animateElements ? 1.0 : 0.0)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateElements = true
            }
        }
        .overlay(
            // Success animation overlay
            Group {
                if showPurchaseAnimation {
                    SuccessAnimationView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
    
    private func purchasePro() async {
        isPurchasing = true
        
        do {
            guard let product = storeKitManager.products.first else {
                throw StoreError.failedVerification
            }
            
            try await storeKitManager.purchase(product)
            
            // Update AppStore with Pro status
            if let expiryDate = storeKitManager.getProExpiryDate() {
                store.upgradeToProUser(expiryDate: expiryDate)
            }
            
            // Show success animation
            showPurchaseAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
            
        } catch {
            // Handle error - could show alert
            print("Purchase failed: \(error)")
        }
        
        isPurchasing = false
    }
    
    private func restorePurchases() async {
        isPurchasing = true
        
        do {
            await storeKitManager.restorePurchases()
            
            // Update AppStore with Pro status
            if storeKitManager.isProUser() {
                if let expiryDate = storeKitManager.getProExpiryDate() {
                    store.upgradeToProUser(expiryDate: expiryDate)
                }
                
                // Show success animation
                showPurchaseAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
            
        } catch {
            // Handle error - could show alert
            print("Restore failed: \(error)")
        }
        
        isPurchasing = false
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    let iconColor: Color
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.mint.opacity(0.2), Color.gray.opacity(0.15), Color.mint.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 140, height: 140)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                            .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(animate ? 1.0 : 0.9)
        .opacity(animate ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                animate = true
            }
        }
    }
}

struct TrustIndicator: View {
    let icon: String
    let text: String
    let iconColor: Color
    
    init(icon: String, text: String, iconColor: Color = .green) {
        self.icon = icon
        self.text = text
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(iconColor)
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct SuccessAnimationView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                        .scaleEffect(animate ? 1.2 : 0.8)
                        .opacity(animate ? 0.0 : 1.0)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1.0 : 0.5)
                        .opacity(animate ? 1.0 : 0.0)
                }
                
                Text("Welcome to Pro!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animate = true
            }
        }
    }
}

// MARK: - Legacy LeaderboardView (keeping for compatibility)

struct LeaderboardView: View {
    var body: some View {
        ProUpgradeView()
    }
}

struct LeaderboardPlayer {
    let name: String
    let xp: Int
    let rank: Int
    let avatar: String
    let streak: Int
}

struct PodiumCard: View {
    let player: LeaderboardPlayer
    let position: Int
    let isCurrentUser: Bool
    
    var height: CGFloat {
        switch position {
        case 1: return 120
        case 2: return 100
        case 3: return 80
        default: return 60
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: position == 1 ? [.yellow, .orange] :
                                   position == 2 ? [.gray, .gray.opacity(0.7)] :
                                   [.brown, .brown.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Text("\(position)")
                    .font(Brand.headlineFont)
                    .foregroundColor(.white)
            }
            
            // Player info
            VStack(spacing: 4) {
                Text(player.name)
                    .font(Brand.subheadlineFont)
                    .foregroundColor(isCurrentUser ? Brand.teal : Brand.textPrimary)
                
                Text("\(player.xp) XP")
                    .font(Brand.bodyFont)
                    .foregroundColor(Brand.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Brand.teal)
                        .font(.caption)
                    Text("\(player.streak)")
                        .font(Brand.smallFont)
                        .foregroundColor(Brand.teal)
                }
            }
        }
        .padding(16)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isCurrentUser ? Color.mint.opacity(0.5) : .clear, lineWidth: 2)
                )
        )
        .scaleEffect(position == 1 ? 1.1 : 1.0)
    }
}

struct LeaderboardRow: View {
    let player: LeaderboardPlayer
    let rank: Int
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text("\(rank)")
                .font(Brand.headlineFont)
                .foregroundColor(Brand.textSecondary)
                .frame(width: 30, alignment: .leading)
            
            // Avatar
            Image(systemName: player.avatar)
                .font(.title2)
                .foregroundColor(isCurrentUser ? Brand.teal : Brand.textSecondary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isCurrentUser ? Brand.teal.opacity(0.2) : Brand.border)
                )
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(Brand.subheadlineFont)
                    .foregroundColor(isCurrentUser ? Brand.teal : Brand.textPrimary)
                
                HStack(spacing: 12) {
                    Text("\(player.xp) XP")
                        .font(Brand.bodyFont)
                        .foregroundColor(Brand.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Brand.teal)
                            .font(.caption)
                        Text("\(player.streak)")
                            .font(Brand.smallFont)
                            .foregroundColor(Brand.teal)
                    }
                }
            }
            
            Spacer()
            
            // Trophy for top positions
            if rank <= 3 {
                Image(systemName: "trophy.fill")
                    .foregroundColor(rank == 1 ? .yellow : rank == 2 ? .gray : .brown)
                    .font(.title3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCurrentUser ? Color.mint.opacity(0.1) : Color.clear)
                .background(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isCurrentUser ? Color.mint.opacity(0.3) : .clear, lineWidth: 1)
                )
        )
    }
}
