import SwiftUI

struct DailyGoalsView: View {
    @ObservedObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var cardAnimations: [Bool] = Array(repeating: false, count: 3)
    @State private var showCelebration = false
    @State private var completedGoalIndex: Int? = nil
    // Removed unused animation state variables for better performance
    
    private var completedGoalsCount: Int {
        store.dailyGoals.filter { $0.isCompleted }.count
    }
    
    private var totalPossibleXP: Int {
        store.dailyGoals.reduce(0) { $0 + $1.xpReward }
    }
    
    var body: some View {
        ZStack {
            // Simplified background for better performance
            Brand.backgroundGradient
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                        .padding(.top, 20)
                    
                    // Goals
                    goalsSection
                        .padding(.top, 16)
                    
                    // Summary
                    summarySection
                        .padding(.top, 16)
                    
                    // Bottom spacing to fill screen
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            
            // Simplified celebration overlay
            if showCelebration {
                SimpleCelebrationOverlay()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            // Simplified animations for better performance
            startSimplifiedAnimations()
            // Only check and reset if needed (avoid redundant calls)
            // Add safety check to prevent crashes in preview mode
            if !store.isPreviewMode && (store.dailyGoals.isEmpty || store.lastDailyGoalResetDate == nil) {
                store.checkAndResetDailyGoals()
            }
            // Track app opened for daily check-in goal (only if goals exist)
            if !store.dailyGoals.isEmpty {
                store.updateDailyGoalProgress(action: .appOpened)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Brand.textSecondary)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                        )
                }
                
                Spacer()
                
                Text("Daily Goals")
                    .font(Brand.titleFont)
                    .foregroundColor(Brand.textPrimary)
                
                Spacer()
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(Brand.border, lineWidth: 3)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: Double(completedGoalsCount) / 3.0)
                        .stroke(
                            LinearGradient(
                                colors: [Brand.gamificationAccent, Brand.lightCoral],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(completedGoalsCount)")
                        .font(Brand.captionFont)
                        .fontWeight(.bold)
                        .foregroundColor(Brand.textPrimary)
                }
            }
        }
    }
    
    private var goalsSection: some View {
        VStack(spacing: 24) {
            if store.dailyGoals.isEmpty {
                // Fallback when no goals exist
                FuturisticGlassmorphismCard {
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 40))
                            .foregroundColor(Brand.primaryBlue)
                        
                        Text("Generating Daily Goals...")
                            .font(Brand.subheadlineFont)
                            .foregroundColor(Brand.textPrimary)
                        
                        Text("Your personalized goals will appear here")
                            .font(Brand.captionFont)
                            .foregroundColor(Brand.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
            } else {
                ForEach(Array(store.dailyGoals.enumerated()), id: \.element.id) { index, goal in
                    DailyGoalCardView(
                        goal: goal,
                        index: index,
                        cardAnimations: $cardAnimations,
                        onComplete: {
                            completedGoalIndex = index
                            showCelebration = true
                            
                            // Hide celebration after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                showCelebration = false
                                completedGoalIndex = nil
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var summarySection: some View {
        FuturisticGlassmorphismCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Brand.gold)
                    
                    Text("Today's Progress")
                        .font(Brand.subheadlineFont)
                        .foregroundColor(Brand.textPrimary)
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(completedGoalsCount)/3")
                            .font(Brand.headlineFont)
                            .fontWeight(.bold)
                            .foregroundColor(Brand.textPrimary)
                        
                        Text("Goals Completed")
                            .font(Brand.smallFont)
                            .foregroundColor(Brand.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(store.todayDailyGoalsXP) XP")
                            .font(Brand.headlineFont)
                            .fontWeight(.bold)
                            .foregroundColor(Brand.gamificationAccent)
                        
                        Text("Earned Today")
                            .font(Brand.smallFont)
                            .foregroundColor(Brand.textSecondary)
                    }
                }
                
                if completedGoalsCount == 3 {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Brand.gold)
                        
                        Text("All goals completed! +25 bonus XP")
                            .font(Brand.captionFont)
                            .foregroundColor(Brand.gold)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
        }
    }
    
    // Removed todayDateString function since date is no longer displayed
    
    private func startSimplifiedAnimations() {
        // Simplified staggered animations for better performance
        // Ensure we don't exceed array bounds
        let maxIndex = min(cardAnimations.count, store.dailyGoals.count, 3)
        for i in 0..<maxIndex {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeOut(duration: 0.6)) {
                    if i < cardAnimations.count {
                        cardAnimations[i] = true
                    }
                }
            }
        }
    }
}

struct DailyGoalCardView: View {
    let goal: DailyGoal
    let index: Int
    @Binding var cardAnimations: [Bool]
    let onComplete: () -> Void
    
    // Removed unused state variables for better performance
    
    var body: some View {
        FuturisticGlassmorphismCard {
            HStack(spacing: 16) {
                // Simplified icon with subtle gradient
                ZStack {
                    // Background circle with subtle gradient
                    Circle()
                        .fill(goal.type.gradient)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: goal.type.color.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Icon
                    Image(systemName: goal.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(goal.title)
                            .font(Brand.subheadlineFont)
                            .fontWeight(.bold)
                            .foregroundColor(Brand.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        // XP badge - only show for incomplete goals
                        if !goal.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Brand.gold)
                                
                                Text("\(goal.xpReward)")
                                    .font(Brand.smallFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(Brand.gold)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Brand.gold.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(Brand.gold.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    Text(goal.description)
                        .font(Brand.captionFont)
                        .foregroundColor(Brand.textSecondary)
                        .lineLimit(2)
                    
                    // Simplified progress bar
                    if !goal.isCompleted {
                        HStack(spacing: 8) {
                            Text("\(goal.currentProgress)/\(goal.targetValue)")
                                .font(Brand.smallFont)
                                .foregroundColor(Brand.textSecondary)
                            
                            Spacer()
                            
                            Text("\(Int(goal.progressPercentage * 100))%")
                                .font(Brand.smallFont)
                                .fontWeight(.medium)
                                .foregroundColor(goal.type.color)
                        }
                        
                        // Simple progress bar
                        ProgressView(value: goal.progressPercentage)
                            .tint(goal.type.color.opacity(0.7))
                            .scaleEffect(x: 1, y: 0.8)
                    } else {
                        // Completion indicator
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Brand.emerald)
                            
                            Text("Completed!")
                                .font(Brand.captionFont)
                                .fontWeight(.medium)
                                .foregroundColor(Brand.emerald)
                            
                            Spacer()
                        }
                    }
                }
                
                // Completion checkmark
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Brand.emerald)
                        .scaleEffect(goal.isCompleted ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: goal.isCompleted)
                }
            }
            .padding(24)
        }
        .scaleEffect((index < cardAnimations.count && cardAnimations[index]) ? 1.0 : 0.95)
        .opacity((index < cardAnimations.count && cardAnimations[index]) ? 1.0 : 0.0)
        .offset(y: (index < cardAnimations.count && cardAnimations[index]) ? 0 : 20)
    }
}

struct SimpleCelebrationOverlay: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Simplified celebration with fewer particles
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(celebrationColors[index % celebrationColors.count])
                    .frame(width: 6)
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : 0,
                        y: animate ? CGFloat.random(in: -300...300) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                        .delay(Double(index) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
    
    private let celebrationColors: [Color] = [
        Brand.gamificationAccent.opacity(0.8),
        Brand.gold.opacity(0.8),
        Brand.emerald.opacity(0.8),
        Brand.primaryBlue.opacity(0.8),
        Brand.lightCoral.opacity(0.8)
    ]
}

#Preview {
    let previewStore = AppStore()
    // Set preview mode to prevent crashes
    previewStore.isPreviewMode = true
    // Initialize preview store with sample data
    previewStore.dailyGoals = [
        DailyGoal(title: "Daily Check-in", description: "Open the app today", type: .simple, icon: "house.fill", targetValue: 1),
        DailyGoal(title: "Question Master", description: "Get 10 questions right", type: .moderate, icon: "checkmark.circle.fill", targetValue: 10),
        DailyGoal(title: "Perfect Score", description: "Complete a lesson perfectly", type: .advanced, icon: "crown.fill", targetValue: 1)
    ]
    previewStore.lastDailyGoalResetDate = Date()
    previewStore.todayDailyGoalsXP = 45
    
    return DailyGoalsView(store: previewStore)
        .preferredColorScheme(.light)
}

#Preview("Empty Goals") {
    let previewStore = AppStore()
    // Set preview mode to prevent crashes
    previewStore.isPreviewMode = true
    // Test with empty goals to ensure no crashes
    previewStore.dailyGoals = []
    previewStore.lastDailyGoalResetDate = Date()
    previewStore.todayDailyGoalsXP = 0
    
    return DailyGoalsView(store: previewStore)
        .preferredColorScheme(.light)
}
