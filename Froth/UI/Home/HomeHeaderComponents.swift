import SwiftUI

struct LevelBadge: View {
    let level: Int
    let xp: Int
    @State private var glow: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Brand.goldGradient)
                .frame(width: 54, height: 54)
                .shadow(color: Brand.gold.opacity(0.45), radius: glow ? 16 : 8)
            Circle()
                .stroke(Brand.white.opacity(0.6), lineWidth: 1)
                .frame(width: 54, height: 54)
            VStack(spacing: 0) {
                Text("Lvl")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Brand.navy)
                Text("\(level)")
                    .font(.headline.weight(.heavy))
                    .foregroundColor(Brand.navy)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                glow.toggle()
            }
        }
        .accessibilityLabel("Level \(level), \(xp) XP")
    }
}

struct StreakFlicker: View {
    let days: Int
    @State private var flicker: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Brand.gold, Brand.gold.opacity(0.6))
                .scaleEffect(flicker ? 1.08 : 0.94)
                .shadow(color: Brand.gold.opacity(0.6), radius: flicker ? 10 : 4)
            Text("\(days) day streak")
                .font(.caption.weight(.semibold))
                .foregroundColor(Brand.textSecondary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                flicker.toggle()
            }
        }
    }
}


