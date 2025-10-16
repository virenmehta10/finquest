import SwiftUI
import Combine
import Charts

// MARK: Leaderboard (mocked)

struct LeaderboardView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTimeframe: TimeFrame = .weekly
    
    enum TimeFrame: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case allTime = "All Time"
    }
    
    // Mock data - in a real app, this would come from a server
    let players = [
        LeaderboardPlayer(name: "Viren", xp: 1220, rank: 1, avatar: "person.circle.fill", streak: 15),
        LeaderboardPlayer(name: "Gia", xp: 980, rank: 2, avatar: "person.circle.fill", streak: 12),
        LeaderboardPlayer(name: "Alex", xp: 680, rank: 3, avatar: "person.circle.fill", streak: 8),
        LeaderboardPlayer(name: "Viren", xp: 420, rank: 4, avatar: "person.circle.fill", streak: 5),
        LeaderboardPlayer(name: "Sarah", xp: 350, rank: 5, avatar: "person.circle.fill", streak: 3),
        LeaderboardPlayer(name: "Mike", xp: 280, rank: 6, avatar: "person.circle.fill", streak: 2)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with timeframe selector
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Text("Upgrade to Pro!")
                            .font(.largeTitle.weight(.bold))
                        Spacer()
                    }
                }
                .padding(.vertical, 16)
                .background(Material.ultraThinMaterial)
                
                // Pro content
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Button(action: {
                            // TODO: Trigger purchase flow
                        }) {
                            VStack(spacing: 12) {
                                Text("$20 lifetime access")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.white)
                                VStack(spacing: 6) {
                                    Text("Pro benefits include:")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("- Access to explanations")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        Text("- Unlock all modules")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(24)
                            .background(
                                LinearGradient(
                                    colors: [Brand.mint, Brand.primaryBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(height: geo.size.height * 0.66)
                        .padding(20)
                    }
                }
            }
        }
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
