import SwiftUI
import Combine
import Charts
import AudioToolbox
import UIKit

// MARK: - Finance Road Quest

struct QuestView: View {
    @EnvironmentObject var store: AppStore
    @State private var appear = false
    @State private var showUnlockAnimation = false
    @State private var unlockedLessonIndex: Int? = nil
    @State private var isTransitioning = false
    @State private var previousModule: String = ""
    @State private var roadGlowAnimation = false
    @State private var showProUpgrade = false
    
    private var unlockedCount: Int {
        max(1, store.completedLessonIDs.count + 1)
    }
    
    // Per-module unlock logic: Level 1 is always unlocked, Level 2 unlocks after Level 1 completion, Levels 3+ require pro
    private func isLessonUnlocked(lesson: Lesson, completedIDs: Set<UUID>) -> Bool {
        let moduleLessons = store.getCurrentModuleLessons()
        guard let idx = moduleLessons.firstIndex(where: { $0.id == lesson.id }) else { return false }
        
        // Level 1 is always unlocked
        if idx == 0 {
            return true
        }
        
        // Level 2 unlocks after Level 1 is completed
        if idx == 1 {
            let level1 = moduleLessons[0]
            return completedIDs.contains(level1.id)
        }
        
        // Levels 3+ require pro access AND previous level completion
        if idx >= 2 {
            let prev = moduleLessons[idx - 1]
            return store.isProUser && completedIDs.contains(prev.id)
        }
        
        return false
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Enhanced animated background with multiple layers
                ZStack {
                    // App-themed red/blue gradient background - covers entire screen
                    RedBlueSoftBackground()
                        .ignoresSafeArea(.all)
                    }
                    
                    ScrollView(showsIndicators: false) {
                        ZStack(alignment: .top) {
                            // Enhanced curvy road path behind nodes with glowing effects
                            EnhancedQuestRoadView(
                                roadGlowAnimation: roadGlowAnimation,
                                completedCount: store.completedLessonIDs.count
                            )
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 24) {
                                // Four levels for the selected module
                                VStack(spacing: 50) {
                                    let moduleLessons = store.getCurrentModuleLessons()
                                    ForEach(moduleLessons.indices, id: \.self) { index in
                                        let lesson = moduleLessons[index]
                                        let isUnlocked = isLessonUnlocked(lesson: lesson, completedIDs: store.completedLessonIDs)
                                        QuestLevelNodeView(lesson: lesson, index: index, isUnlocked: isUnlocked, geometry: geometry, showProUpgrade: $showProUpgrade)
                                            .transition(.asymmetric(
                                                insertion: .scale(scale: 0.7).combined(with: .opacity).combined(with: .offset(y: 50)),
                                                removal: .scale(scale: 0.7).combined(with: .opacity).combined(with: .offset(y: -50))
                                            ))
                                            .animation(.spring(response: 0.7, dampingFraction: 0.75, blendDuration: 0).delay(Double(index) * 0.1), value: store.currentModule)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 10) // Adjusted to match road start
                                .padding(.bottom, 200)
                                .id(store.currentModule) // This forces a complete re-render when module changes
                                .animation(.spring(response: 0.7, dampingFraction: 0.75, blendDuration: 0), value: store.currentModule)
                            }
                        }
                    }
                }
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(store.currentModule)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .offset(y: 8) // Move down slightly
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.currentModule)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            let orderedModules = [
                                "Accounting Basics",
                                "Valuation Techniques",
                                "DCF Fundamentals",
                                "LBO Fundamentals",
                                "M&A Fundamentals"
                            ]
                            ForEach(orderedModules, id: \.self) { module in
                                Button(module) {
                                    // Add haptic feedback
                                    if store.hapticsEnabled {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                    }
                                    
                                    // Update module with animation
                                    withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                                        store.currentModule = module
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundColor(.primary)
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                }
                .overlay(
                    // Unlock animation overlay
                    Group {
                        if showUnlockAnimation, let unlockedIndex = unlockedLessonIndex {
                            UnlockAnimationView(
                                lessonIndex: unlockedIndex,
                                onDismiss: {
                                    showUnlockAnimation = false
                                    unlockedLessonIndex = nil
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                )
                .onAppear {
                    appear = true
                    roadGlowAnimation = true
                    
                    // Check if we should show unlock animation in selected module
                    if store.shouldShowUnlockAnimation {
                        let moduleLessons = store.getCurrentModuleLessons()
                        for (index, lesson) in moduleLessons.enumerated() {
                            let isUnlocked = isLessonUnlocked(lesson: lesson, completedIDs: store.completedLessonIDs)
                            if isUnlocked && !store.completedLessonIDs.contains(lesson.id) {
                                unlockedLessonIndex = index
                                break
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showUnlockAnimation = true
                        }
                        store.shouldShowUnlockAnimation = false
                    }
                }
            }
        }
        .sheet(isPresented: $showProUpgrade) {
            ProUpgradeView()
        }
    }
}

// MARK: - Enhanced Gamified Road Components

struct EnhancedQuestRoadView: View {
    @EnvironmentObject var store: AppStore
    let roadGlowAnimation: Bool
    let completedCount: Int
    @State private var sparkleAnimation = false
    @State private var roadPulseAnimation = false
    @State private var progressAnimation = false
    
    private var progressPercentage: Double {
        let totalLessons = ContentProvider.sampleLessons.count
        return Double(completedCount) / Double(max(1, totalLessons))
    }
    
    var body: some View {
        ZStack {
            // Subtle road border for definition
            QuestCurvyRoad()
                .stroke(
                    Color.black.opacity(0.08),
                    style: StrokeStyle(lineWidth: 32, lineCap: .round)
                )
            
            // Main road surface with elegant gradient
            QuestCurvyRoad()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.94, blue: 0.90), // Light warm beige
                            Color(red: 0.94, green: 0.91, blue: 0.87), // Slightly darker
                            Color(red: 0.92, green: 0.89, blue: 0.84)  // Darker for depth
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 28, lineCap: .round)
                )
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                .shadow(color: Brand.gamificationAccent.opacity(0.05), radius: 8, x: 0, y: 3)
            
            // Removed progress overlay (sludge animation) - road stays clean
            
            // Removed glow effect for completed sections - keeping road clean
            
        }
        .onAppear {
            sparkleAnimation = true
            roadPulseAnimation = true
            progressAnimation = true
        }
    }
}

// MARK: - Duolingo-style road components

struct QuestCurvyRoad: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let startY: CGFloat = 10  // Pushed road up further
        let segmentHeight: CGFloat = 180
        let amplitude: CGFloat = min(rect.width * 0.22, 120)
        var currentY = startY
        var direction: CGFloat = 1
        // Start centered horizontally
        p.move(to: CGPoint(x: rect.midX, y: currentY))
        for _ in 0..<8 {
            let cp1 = CGPoint(x: rect.midX + amplitude * direction, y: currentY + segmentHeight * 0.35)
            let cp2 = CGPoint(x: rect.midX - amplitude * direction, y: currentY + segmentHeight * 0.65)
            let end = CGPoint(x: rect.midX, y: currentY + segmentHeight)
            p.addCurve(to: end, control1: cp1, control2: cp2)
            currentY += segmentHeight
            direction *= -1
        }
        return p
    }
}

struct QuestRoadView: View {
    @EnvironmentObject var store: AppStore
    @State private var sparkleAnimation = false
    
    private var progressPercentage: Double {
        let completedCount = store.completedLessonIDs.count
        let totalLessons = ContentProvider.sampleLessons.count
        return Double(completedCount) / Double(max(1, totalLessons))
    }
    
    var body: some View {
        ZStack {
            // Simple constant color road background
            QuestCurvyRoad()
                .stroke(
                    Color(red: 0.96, green: 0.92, blue: 0.85), // Light golden beige
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Progress overlay with enhanced colors
            QuestCurvyRoad()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    LinearGradient(
                        colors: [
                            Brand.primaryBlue,
                            Brand.gamificationAccent,
                            Brand.lightCoral,
                            Brand.softBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .shadow(color: Brand.primaryBlue.opacity(0.3), radius: 3, x: 0, y: 1)
                .animation(.easeInOut(duration: 1.0), value: progressPercentage)
        }
        .onAppear {
            sparkleAnimation = true
        }
    }
}

// MARK: - Themed Backgrounds

struct MintGoldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.98, blue: 0.95), // very light mint
                    Color(red: 1.00, green: 0.97, blue: 0.90)  // soft gold-cream
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.white.opacity(0.25), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 280
            )
            RadialGradient(
                colors: [Color.white.opacity(0.18), Color.clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 360
            )
        }
    }
}

struct RedBlueSoftBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.73, blue: 0.66), // soft coral/red
                    Color(red: 0.78, green: 0.89, blue: 0.98)  // soft sky blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.35)
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.96, green: 0.98, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.plusLighter)
            // Subtle color tints around the road area
            RadialGradient(
                colors: [Color(red: 0.60, green: 0.80, blue: 1.00).opacity(0.18), Color.clear], // blue tint
                center: .center,
                startRadius: 20,
                endRadius: 280
            )
            RadialGradient(
                colors: [Color(red: 1.00, green: 0.68, blue: 0.40).opacity(0.05), Color.clear], // golden tint - reduced opacity
                center: .bottom,
                startRadius: 0,
                endRadius: 360
            )
            RadialGradient(
                colors: [Color(red: 1.00, green: 0.55, blue: 0.45).opacity(0.03), Color.clear], // orange-red tint - reduced opacity
                center: .top,
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                colors: [Color.white.opacity(0.20), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 260
            )
            RadialGradient(
                colors: [Color.white.opacity(0.18), Color.clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 340
            )
        }
    }
}

struct QuestLevelNodeView: View {
    @EnvironmentObject var store: AppStore
    let lesson: Lesson
    let index: Int
    let isUnlocked: Bool
    let geometry: GeometryProxy
    @Binding var showProUpgrade: Bool
    @State private var hasAppeared = false
    
    private var isLocked: Bool {
        !store.canAccessLesson(lesson: lesson)
    }
    
    private var isProLocked: Bool {
        let moduleLessons = store.getCurrentModuleLessons()
        guard let lessonIndex = moduleLessons.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        // Levels 3+ (indices 2+) require pro access
        return lessonIndex >= 2 && !store.isProUser
    }
    
    private var nodeSide: HorizontalAlignment { index % 2 == 0 ? .leading : .trailing }
    private var xOffset: CGFloat {
        // Push nodes slightly more outward from road centerline
        let maxOffset = min(geometry.size.width * 0.24, 170)
        // Move left-side nodes (Financial Statements, DCF Fundamentals, LBO Fundamentals) further left
        let leftOffset = min(geometry.size.width * 0.32, 230) // Increased offset for left nodes - one more tick
        // Move right-side nodes (Accounting Basics, Valuation & EV, M&A Fundamentals) further right
        let rightOffset = min(geometry.size.width * 0.28, 200) // Increased offset for right nodes
        return index % 2 == 0 ? -leftOffset : rightOffset
    }
    
    var body: some View {
        HStack { content }
            .frame(maxWidth: .infinity, alignment: .center)
            .offset(x: xOffset)
            .scaleEffect(isUnlocked && !isLocked ? 1.0 : 0.95)
            .opacity(isUnlocked && !isLocked ? 1.0 : (isProLocked ? 0.6 : 0.7))
            .animation(.easeInOut(duration: 0.3), value: isUnlocked)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.15)) {
                    hasAppeared = true
                }
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.8)
            .opacity(hasAppeared ? 1.0 : 0.0)
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked && !isLocked ? Color.white : (isProLocked ? Color.white.opacity(0.6) : Color.white.opacity(0.75)))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(isProLocked ? Color.orange.opacity(0.6) : Color.black.opacity(0.25), lineWidth: isProLocked ? 2.0 : 1.5)
                    )
                    .shadow(color: isProLocked ? Color.orange.opacity(0.2) : .black.opacity(0.08), radius: isProLocked ? 12 : 8, x: 0, y: 4)
                if store.completedLessonIDs.contains(lesson.id) {
                    // Completed lesson - green checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                } else if isUnlocked && !isLocked {
                    // Unlocked but not completed - blue flag
                    NavigationLink(destination: LessonPlayView(lesson: lesson)) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                    }
                } else if isLocked {
                    // Pro locked lesson - premium lock with crown
                    Button(action: {
                        showProUpgrade = true
                    }) {
                        ZStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.yellow)
                                .offset(x: 10, y: -10)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // Regular locked lesson - red lock
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.3)) // Slight red tinge
                }
            }
            
            VStack(spacing: 4) {
                Text(lesson.title.components(separatedBy: " - ").last ?? lesson.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 150)
                
                if isProLocked {
                    Text("PRO")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [Color.orange, Color.yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                }
            }
            
            Text("\(lesson.questions.count) Questions")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct ModernRoadVisualization: View {
    @EnvironmentObject var store: AppStore
    let geometry: GeometryProxy
    @State private var appear = false
    
    private func isLessonUnlocked(lesson: Lesson, completedIDs: Set<UUID>) -> Bool {
        // If no prerequisites, lesson is unlocked
        if lesson.prerequisites.isEmpty {
            return true
        }
        
        // Check if all prerequisite lessons are completed
        for prerequisiteTitle in lesson.prerequisites {
            let prerequisiteLesson = ContentProvider.sampleLessons.first { $0.title == prerequisiteTitle }
            if let prerequisiteLesson = prerequisiteLesson {
                if !completedIDs.contains(prerequisiteLesson.id) {
                    return false
                }
            }
        }
        
        return true
    }
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 24, shadowRadius: 15) {
            VStack(spacing: 20) {
                Text("Learning Path")
                    .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 16) {
                        ForEach(ContentProvider.sampleLessons.indices, id: \.self) { index in
                            let lesson = ContentProvider.sampleLessons[index]
                            let isCompleted = store.completedLessonIDs.contains(lesson.id)
                            let isUnlocked = isLessonUnlocked(lesson: lesson, completedIDs: store.completedLessonIDs)
                            
                        ModernRoadLessonNode(
                                lesson: lesson,
                                index: index,
                                isCompleted: isCompleted,
                                isUnlocked: isUnlocked,
                            isLast: index == ContentProvider.sampleLessons.count - 1,
                            geometry: geometry
                        )
                    }
                }
                .padding(min(20, geometry.size.width * 0.05))
            }
            .scaleEffect(appear ? 1 : 0.9)
            .opacity(appear ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: appear)
            .onAppear {
                appear = true
            }
        }
    }
}

struct ModernRoadLessonNode: View {
    @EnvironmentObject var store: AppStore
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let isLast: Bool
    let geometry: GeometryProxy
    @State private var appear = false
    @State private var pulseAnimation = false
    @State private var glowAnimation = false
    @State private var sparkleAnimation = false
    @State private var hoverEffect = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced lesson node with animations
            NavigationLink(destination: LessonPlayView(lesson: lesson)) {
                ZStack {
                    // Outer glow effect for unlocked/completed lessons
                    if isUnlocked || isCompleted {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (isCompleted ? Brand.gamificationAccent : lesson.type.color).opacity(0.3),
                                        (isCompleted ? Brand.gamificationAccent : lesson.type.color).opacity(0.1),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: min(80, geometry.size.width * 0.18), height: min(80, geometry.size.width * 0.18))
                            .blur(radius: 4)
                            .scaleEffect(glowAnimation ? 1.2 : 1.0)
                            .opacity(glowAnimation ? 0.8 : 0.4)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowAnimation)
                    }
                    
                    // Main node with enhanced gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isCompleted ? 
                                    [Brand.gamificationAccent, Brand.lightCoral] : 
                                    isUnlocked ? 
                                        [lesson.type.color, lesson.type.color.opacity(0.8)] : 
                                        [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: min(60, geometry.size.width * 0.14), height: min(60, geometry.size.width * 0.14))
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.8),
                                            Color.white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: (isCompleted ? Brand.gamificationAccent : lesson.type.color).opacity(0.4), radius: pulseAnimation ? 15 : 8, x: 0, y: 6)
                        .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                        .scaleEffect(hoverEffect ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hoverEffect)
                    
                    // Icon with enhanced styling
                    ZStack {
                        // Icon background for better visibility
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: min(35, geometry.size.width * 0.08), height: min(35, geometry.size.width * 0.08))
                            .blur(radius: 1)
                    
                    Image(systemName: isCompleted ? "checkmark" : lesson.type.icon)
                            .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                        .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    
                    // Celebration sparkles for completed lessons
                    if isCompleted {
                        ForEach(0..<6, id: \.self) { sparkleIndex in
                            Image(systemName: "sparkles")
                                .font(.system(size: 8))
                                .foregroundColor(Brand.gamificationAccent)
                                .offset(
                                    x: cos(Double(sparkleIndex) * .pi / 3) * 25,
                                    y: sin(Double(sparkleIndex) * .pi / 3) * 25
                                )
                                .opacity(sparkleAnimation ? 1.0 : 0.0)
                                .scaleEffect(sparkleAnimation ? 1.5 : 0.5)
                                .animation(
                                    .easeOut(duration: 0.8)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(sparkleIndex) * 0.1),
                                    value: sparkleAnimation
                                )
                        }
                    }
                }
            }
            .disabled(!isUnlocked)
            .onHover { hovering in
                if isUnlocked {
                    hoverEffect = hovering
                }
            }
            
            // Enhanced lesson info with better typography
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.title)
                    .font(.system(size: min(16, geometry.size.width * 0.04), weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(lesson.description)
                    .font(.system(size: min(14, geometry.size.width * 0.035)))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    // Enhanced type indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(lesson.type.color)
                            .frame(width: 8, height: 8)
                    Text(lesson.type.displayName)
                        .font(.system(size: min(12, geometry.size.width * 0.03), weight: .semibold))
                        .foregroundColor(lesson.type.color)
                    }
                    
                    Spacer()
                    
                    // Enhanced XP indicator
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Brand.gold)
                    Text("\(lesson.xpReward) XP")
                        .font(.system(size: min(12, geometry.size.width * 0.03), weight: .semibold))
                            .foregroundColor(Brand.gold)
                    }
                }
            }
            
            Spacer()
            
            // Enhanced status indicator with animations
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(Brand.gamificationAccent.opacity(0.2))
                        .frame(width: min(30, geometry.size.width * 0.07), height: min(30, geometry.size.width * 0.07))
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: min(20, geometry.size.width * 0.05)))
                        .foregroundColor(Brand.gamificationAccent)
                }
            } else if !isUnlocked {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: min(30, geometry.size.width * 0.07), height: min(30, geometry.size.width * 0.07))
                    
                Image(systemName: "lock.fill")
                        .font(.system(size: min(16, geometry.size.width * 0.04)))
                    .foregroundColor(.gray)
                }
            }
        }
        .padding(min(16, geometry.size.width * 0.04))
        .background(
            ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                // Subtle inner glow for unlocked lessons
                if isUnlocked || isCompleted {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            RadialGradient(
                                colors: [
                                    (isCompleted ? Brand.gamificationAccent : lesson.type.color).opacity(0.05),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            isCompleted ? Brand.gamificationAccent.opacity(0.4) :
                            isUnlocked ? lesson.type.color.opacity(0.3) : Color.gray.opacity(0.1),
                            isCompleted ? Brand.gamificationAccent.opacity(0.2) :
                            isUnlocked ? lesson.type.color.opacity(0.1) : Color.gray.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: appear)
        .onAppear {
            appear = true
            if isUnlocked || isCompleted {
                pulseAnimation = true
                glowAnimation = true
            }
            if isCompleted {
                sparkleAnimation = true
            }
        }
    }
}

struct QuestNode: View {
    @EnvironmentObject var store: AppStore
    let lesson: Lesson
    let index: Int
    let isUnlocked: Bool
    @State private var appear = false
    
    var body: some View {
        NavigationLink(destination: LessonPlayView(lesson: lesson)) {
            VStack(spacing: 12) {
                ZStack {
                    // Glow
                    Circle()
                        .fill(RadialGradient(colors: [lesson.difficulty.color.opacity(0.35), .clear], center: .center, startRadius: 0, endRadius: 60))
                        .frame(width: 120, height: 120)
                        .blur(radius: 14)
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.9)
                    
                    // Node
                    Circle()
                        .fill(LinearGradient(colors: [lesson.difficulty.color, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 96, height: 96)
                        .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 3))
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: iconName)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                                Text("\(lesson.xpReward)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                        )
                        .saturation(isUnlocked ? 1.0 : 0.0)
                        .opacity(isUnlocked ? 1.0 : 0.5)
                }
                
                VStack(spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Text(lesson.difficulty.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundColor(lesson.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.ultraThinMaterial))
                }
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 16)
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(Double(index) * 0.04)) {
                    appear = true
                }
            }
        }
        .disabled(!isUnlocked)
    }
    
    var iconName: String {
        switch lesson.type {
        case .flashcards: return "rectangle.and.pencil.and.ellipsis"
        case .multipleChoice: return "checkmark.circle"
        case .miniCase: return "brain.head.profile"
        case .caseStudy: return "doc.text.magnifyingglass"
        case .technicalInterview: return "briefcase"
        }
    }
}

// MARK: - Mascot Assistant

struct MascotAssistantView: View {
    @Binding var isShowing: Bool
    @State private var bounce = false
    @State private var messageIndex = 0
    let messages = [
        "Focus on fundamentals in your studies!",
        "Practice makes perfect progress.",
        "Stay consistent with your learning goals!"
    ]
    
    var body: some View {
        if isShowing {
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(messages[messageIndex])
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2), lineWidth: 1))
                    Button("Got it") {
                        withAnimation(.spring()) { isShowing = false }
                    }
                    .font(.caption.bold())
                    .buttonStyle(.borderedProminent)
                }
                
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.mint, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                        .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        .scaleEffect(bounce ? 1.05 : 0.95)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: bounce)
                    Image(systemName: "owl")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                bounce = true
                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                    withAnimation { messageIndex = (messageIndex + 1) % messages.count }
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

// MARK: - Daily Quest Banner

struct DailyQuestBanner: View {
    @EnvironmentObject var store: AppStore
    @State private var shimmer = false
    
    var progress: Double {
        min(1.0, Double(store.currentDayXP) / Double(max(1, store.dailyGoal)))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(colors: [.yellow.opacity(0.3), .orange.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.3), lineWidth: 1))
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Daily Quest")
                    .font(.headline.weight(.bold))
                Text("Earn \(store.dailyGoal) XP to keep your streak!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ProgressView(value: progress)
                    .tint(.orange)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text(progress >= 1.0 ? "Claim" : "Start")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.orange))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                if shimmer {
                    LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 80)
                        .rotationEffect(.degrees(15))
                        .offset(x: shimmer ? 220 : -220)
                        .animation(.linear(duration: 1.6).repeatForever(autoreverses: false), value: shimmer)
                }
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.15), lineWidth: 1))
        .onAppear { shimmer = true }
    }
}

// MARK: - New Brand + Home Content moved to UI/


// MARK: - Continue Learning Card

struct ContinueLearningCard: View {
    @EnvironmentObject var store: AppStore
    let lesson: Lesson
    @State private var pulse = false
    
    var body: some View {
        NavigationLink(destination: LessonPlayView(lesson: lesson)) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                        .scaleEffect(pulse ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                    
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Continue Learning")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text(lesson.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(lesson.xpReward) XP")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(lesson.difficulty.rawValue)
                            .font(.caption.weight(.bold))
                            .foregroundColor(lesson.difficulty.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(lesson.difficulty.color.opacity(0.15)))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    )
                    .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Road Components

struct RoadBackground: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<ContentProvider.sampleLessons.count, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .padding(.horizontal, 40)
                
                if index < ContentProvider.sampleLessons.count - 1 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 60)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
}

struct RoadLessonNode: View {
    @EnvironmentObject var store: AppStore
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let isLast: Bool
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side - Lesson node
            NavigationLink(destination: LessonPlayView(lesson: lesson)) {
                VStack(spacing: 8) {
                    ZStack {
                        // Road connection
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2, height: 30)
                            .offset(y: -15)
                        
                        // Node
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isCompleted ? [.green, .mint] : isUnlocked ? [.blue, .purple] : [.gray, .gray.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 3)
                            )
                            .overlay(
                                Image(systemName: isCompleted ? "checkmark" : iconName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: shadowColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    
                    Text(lesson.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 80)
                }
            }
            .disabled(!isUnlocked)
            .opacity(isUnlocked ? 1.0 : 0.5)
            
            Spacer()
            
            // Right side - Module info
            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.category)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(lesson.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(lesson.xpReward) XP")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(lesson.difficulty.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundColor(lesson.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(lesson.difficulty.color.opacity(0.15)))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .opacity(appear ? 1 : 0)
        .offset(x: appear ? 0 : -30)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                appear = true
            }
        }
    }
    
    var iconName: String {
        switch lesson.type {
        case .flashcards: return "rectangle.and.pencil.and.ellipsis"
        case .multipleChoice: return "checkmark.circle"
        case .miniCase: return "brain.head.profile"
        case .caseStudy: return "doc.text.magnifyingglass"
        case .technicalInterview: return "briefcase"
        }
    }
    
    var shadowColor: Color {
        if isCompleted {
            return .green
        } else if isUnlocked {
            return .blue
        } else {
            return .gray
        }
    }
}

// MARK: - Island Exploration Theme

struct IslandExplorationView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedModule: String = "DCF Fundamentals"
    
    let modules = [
        ("DCF Fundamentals", "Investment Banking", "chart.line.uptrend.xyaxis", Color.blue, 12),
        ("LBO Modeling", "Private Equity", "building.2", Color.purple, 8),
        ("Case Interview", "Management Consulting", "brain.head.profile", Color.green, 15),
        ("Market Sizing", "Strategy", "chart.bar", Color.orange, 6),
        ("Excel Mastery", "Technical Skills", "tablecells", Color.cyan, 10),
        ("Financial Analysis", "Analysis", "doc.text.magnifyingglass", Color.mint, 9)
    ]
    
    var body: some View {
        GeometryReader { geometry in
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                        // Header with glassmorphism
                        VStack(spacing: 16) {
                            Text("Learning Modules")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("Master finance & consulting through structured learning paths")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                    }
                        .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                        // Stats overview with glassmorphism
                        HStack(spacing: 12) {
                            ModernStatCard(
                                title: "Total Modules",
                                value: "\(modules.count)",
                                icon: "square.grid.2x2",
                                color: .blue,
                                geometry: geometry
                            )
                            ModernStatCard(
                                title: "Completed",
                                value: "\(store.completedModules.count)",
                                icon: "checkmark.circle.fill",
                                color: .green,
                                geometry: geometry
                            )
                            ModernStatCard(
                                title: "In Progress",
                                value: "\(modules.count - store.completedModules.count)",
                                icon: "clock.fill",
                                color: .orange,
                                geometry: geometry
                            )
                    }
                    .padding(.horizontal, 20)
                    
                        // Modules grid with responsive design
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        ForEach(modules, id: \.0) { module in
                            NavigationLink(
                                    destination: LessonsView(lessons: ContentProvider.sampleLessons.filter { $0.category == module.0 }, startWithFirst: true)
                            ) {
                                ModernModuleCard(
                                    title: module.0,
                                    category: module.1,
                                    icon: module.2,
                                    color: module.3,
                                    lessonCount: module.4,
                                    isUnlocked: isModuleUnlocked(module.0),
                                        isCompleted: store.completedModules.contains(module.1),
                                        geometry: geometry
                                )
                            }
                            .disabled(!isModuleUnlocked(module.0))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(
                    AnimatedGradientBackground(
                    colors: [
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.08),
                            Color.mint.opacity(0.06),
                            Color.cyan.opacity(0.04)
                        ]
                    )
            )
            .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    func isModuleUnlocked(_ module: String) -> Bool {
        // DCF is always unlocked, others unlock based on completion
        if module == "DCF Fundamentals" { return true }
        
        let moduleOrder = ["DCF Fundamentals", "LBO Modeling", "Case Interview", "Market Sizing", "Excel Mastery", "Financial Analysis"]
        if let currentIndex = moduleOrder.firstIndex(of: module) {
            let previousModule = currentIndex > 0 ? moduleOrder[currentIndex - 1] : nil
            if let previous = previousModule {
                return store.completedModules.contains(previous)
            }
        }
        return false
    }
}

struct ModernModuleCard: View {
    let title: String
    let category: String
    let icon: String
    let color: Color
    let lessonCount: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 24, shadowRadius: 15) {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and status
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isCompleted ? [.green, .mint] : isUnlocked ? [color, color.opacity(0.8)] : [.gray, .gray.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                            .frame(width: min(50, geometry.size.width * 0.12), height: min(50, geometry.size.width * 0.12))
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: isCompleted ? "checkmark" : icon)
                            .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                            .font(.system(size: min(20, geometry.size.width * 0.05)))
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                            .font(.system(size: min(20, geometry.size.width * 0.05)))
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                        .font(.system(size: min(16, geometry.size.width * 0.04), weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(category)
                        .font(.system(size: min(14, geometry.size.width * 0.035)))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(lessonCount) lessons")
                            .font(.system(size: min(12, geometry.size.width * 0.03), weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    if isUnlocked {
                        Text("Start")
                                .font(.system(size: min(12, geometry.size.width * 0.03), weight: .bold))
                            .foregroundColor(.blue)
                    } else {
                        Text("Locked")
                                .font(.system(size: min(12, geometry.size.width * 0.03), weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
            .padding(min(20, geometry.size.width * 0.05))
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.9)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3))) {
                appear = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        GlassmorphismCard(cornerRadius: 20, shadowRadius: 12) {
            VStack(spacing: 12) {
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
                
                Text(value)
                    .font(.system(size: min(20, geometry.size.width * 0.05), weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: min(12, geometry.size.width * 0.03), weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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


// MARK: - UI Components


// MARK: - Button Styles

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


struct DailyGoalCard: View {
    @EnvironmentObject var store: AppStore
    @State private var animateProgress = false
    
    var progress: Double {
        min(1.0, Double(store.currentDayXP) / Double(store.dailyGoal))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))
                    
                Text("Daily Goal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(store.currentDayXP)/\(store.dailyGoal) XP")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            // Enhanced progress bar with gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(.easeInOut(duration: 1.0), value: progress)
                        .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            .frame(height: 10)
            
            if progress >= 1.0 {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18))
                        .scaleEffect(animateProgress ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateProgress)
                    
                    Text("Goal completed! 🎉")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.green)
                }
                .onAppear {
                    animateProgress = true
            }
        }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.05), .cyan.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .blue.opacity(0.1), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct RecentAchievementsCard: View {
    @EnvironmentObject var store: AppStore
    
    var recentAchievements: [Achievement] {
        ContentProvider.achievements.filter { store.achievements.contains($0.id) }.prefix(3).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 18, weight: .semibold))
                    
                Text("Recent Achievements")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                NavigationLink("View All") {
                    AchievementsView()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentAchievements) { achievement in
                        AchievementBadge(achievement: achievement, isUnlocked: true)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.05), .orange.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .yellow.opacity(0.1), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct StreakVisualizationCard: View {
    @EnvironmentObject var store: AppStore
    @State private var animateFlame = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 50, height: 50)
                        .blur(radius: 8)
                        .opacity(animateFlame ? 0.8 : 0.4)
                    
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                        .font(.system(size: 20, weight: .bold))
                        .scaleEffect(animateFlame ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateFlame)
                }
                
                Text("Study Streak")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(store.streakDays) days")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            // Enhanced streak visualization with gradient
            HStack(spacing: 4) {
                ForEach(0..<min(store.streakDays, 30), id: \.self) { day in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red, .orange.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 8, height: 8)
                        .scaleEffect(day == store.streakDays - 1 ? 1.3 : 1.0)
                        .shadow(color: .orange.opacity(0.5), radius: 2, x: 0, y: 1)
                        .animation(.easeInOut(duration: 0.4), value: store.streakDays)
                }
                
                if store.streakDays < 30 {
                    ForEach(store.streakDays..<30, id: \.self) { _ in
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            if store.streakDays >= 7 {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                        .scaleEffect(animateFlame ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateFlame)
                    
                    Text("Amazing streak! Keep it up! 🔥")
                        .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
        }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.05), .red.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .orange.opacity(0.1), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            animateFlame = true
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.rarity.gradient : LinearGradient(
                        colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .font(.title3)
            }
            
            Text(achievement.title)
                .font(.caption.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
        }
        .frame(width: 80)
    }
}

struct CelebrationView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400...0)
                    )
                    .scaleEffect(animate ? 1.5 : 0.5)
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2.0)
                        .delay(Double.random(in: 0...1)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct StreakCelebrationView: View {
    let streak: Int
    @State private var animate = false
    @State private var fadeOut = false
    @State private var fadeIn = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Fire icon with animation
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.orange.opacity(0.8), Color.red.opacity(0.6)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animate)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: animate)
                }
                
                VStack(spacing: 8) {
                    Text("🔥 STREAK!")
                        .font(.title.weight(.black))
                        .foregroundColor(.white)
                    
                    Text("\(streak) correct in a row!")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("Points multiplier: \(streak >= 5 ? "x\(streak >= 10 ? 3 : 2)" : "x1")")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.yellow)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.orange, .red, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
            )
        }
        .opacity(fadeOut ? 0.0 : (fadeIn ? 1.0 : 0.0))
        .scaleEffect(fadeOut ? 0.8 : (fadeIn ? 1.0 : 0.8))
        .animation(.easeOut(duration: 0.5), value: fadeOut)
        .animation(.easeOut(duration: 0.3), value: fadeIn)
        .onAppear {
            fadeIn = true
            animate = true
            
            // Start fade out after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                fadeOut = true
            }
        }
    }
}

struct ProgressRing: View {
    var progress: Double // 0..1
    var size: CGFloat
    var xp: Int
    @State private var animatedProgress: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.3

    var body: some View {
        ZStack {
            // Subtle glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.blue.opacity(glowIntensity * 0.3),
                            Color.cyan.opacity(glowIntensity * 0.2),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.4,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
                .blur(radius: 15)
                .scaleEffect(pulseScale)
            
            // Professional background circle
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.06
                )
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                        .frame(width: size, height: size)
                )
            
            // Professional progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 0.1, green: 0.5, blue: 0.8),
                            Color(red: 0.2, green: 0.7, blue: 0.9),
                            Color(red: 0.1, green: 0.6, blue: 0.7),
                            Color(red: 0.1, green: 0.5, blue: 0.8)
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: size * 0.06, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.blue.opacity(0.2), radius: 6, x: 0, y: 3)
                .animation(.easeInOut(duration: 1.5), value: animatedProgress)
            
            // Subtle animated dots along the progress ring
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .offset(y: -size * 0.5)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(animatedProgress > Double(index) / 8.0 ? 1 : 0)
                    .scaleEffect(animatedProgress > Double(index) / 8.0 ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.3)
                        .delay(Double(index) * 0.1),
                        value: animatedProgress
                    )
            }
            
            // Professional center content
            VStack(spacing: 8) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.3, blue: 0.6),
                                Color(red: 0.2, green: 0.5, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .contentTransition(.numericText())
                Text("to next level")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                    .textCase(.uppercase)
                    .tracking(1.0)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = newValue
            }
        }
    }
}

struct QuickStartCard: View {
    @EnvironmentObject var store: AppStore
    @State private var animateButton = false
    @State private var animateGlow = false
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .blur(radius: 8)
                            .opacity(animateGlow ? 0.6 : 0.3)
                        
                    Image(systemName: "bolt.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                    
                    Text("Daily Sprint")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Text("3 quick questions to keep your streak alive and earn bonus XP!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                        .scaleEffect(animateGlow ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateGlow)
                    
                    Text("+50 bonus XP")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            NavigationLink(destination: LessonsView(lessons: ContentProvider.sampleLessons, startWithFirst: true)) {
                HStack(spacing: 8) {
                    Text("Start")
                        .font(.system(size: 15, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                .scaleEffect(animateButton ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateButton)
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.05), .red.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                            colors: [.white.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
            }
                )
        .shadow(color: .orange.opacity(0.1), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onAppear {
            animateButton = true
            animateGlow = true
        }
    }
}

// MARK: - Missing Views

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: AppStore
    @State private var firstName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var isLoading = false
    @State private var animateFields = false
    @State private var showSuccessAnimation = false
    @State private var animateBackground = false
    
    let onComplete: () -> Void
    
    private var formProgress: Double {
        let completedFields = [firstName.count >= 2, email.contains("@") && email.hasSuffix(".edu"), phoneNumber.filter { $0.isNumber }.count >= 10].filter { $0 }.count
        return Double(completedFields) / 3.0
    }
    
    var body: some View {
        ZStack {
            // Enhanced background with animated elements
            Brand.backgroundGradient
                .ignoresSafeArea(.all)
            
            // Floating animated elements - fixed positions to prevent movement
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Brand.primaryBlue.opacity(0.1), Brand.lightCoral.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .offset(
                        x: CGFloat(index * 100 - 250),
                        y: CGFloat(index * 80 - 200)
                    )
                    .animation(
                        .easeInOut(duration: 4.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animateBackground
                    )
            }
            
            ScrollView {
            VStack(spacing: 0) {
                    // Enhanced header section
                    VStack(spacing: 24) {
                        // App logo/icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Brand.primaryBlue.opacity(0.2), Brand.lightCoral.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Brand.primaryBlue)
                        }
                        .scaleEffect(animateFields ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateFields)
                        
                        // Removed title and subtitle for cleaner design
                        .opacity(animateFields ? 1.0 : 0.0)
                        .offset(y: animateFields ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateFields)
                }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)
                    
                    // Progress indicator
                    VStack(spacing: 12) {
                        HStack {
                            Text("Account Setup")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Brand.textPrimary)
                            
                            Spacer()
                            
                            Text("\(Int(formProgress * 100))% Complete")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Brand.textSecondary)
                        }
                        
                        ProgressView(value: formProgress)
                            .tint(Brand.primaryBlue)
                            .scaleEffect(x: 1, y: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                            )
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                    .opacity(animateFields ? 1.0 : 0.0)
                    .offset(y: animateFields ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateFields)
                    
                    // Enhanced form fields
                    VStack(spacing: 20) {
                        EnhancedFirstNameField(firstName: $firstName)
                            .opacity(animateFields ? 1.0 : 0.0)
                            .offset(x: animateFields ? 0 : -30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: animateFields)
                        
                        EnhancedEmailField(email: $email)
                            .opacity(animateFields ? 1.0 : 0.0)
                            .offset(x: animateFields ? 0 : -30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: animateFields)
                        
                        EnhancedPhoneNumberField(phoneNumber: $phoneNumber)
                            .opacity(animateFields ? 1.0 : 0.0)
                            .offset(x: animateFields ? 0 : -30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.2), value: animateFields)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    
                    Spacer(minLength: 20)
                    
                    // Enhanced continue button
                VStack(spacing: 16) {
                    Button(action: {
                        handleContinue()
                    }) {
                            HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                        .scaleEffect(0.9)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else if showSuccessAnimation {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                            } else {
                                Text("Create Account")
                                        .font(.system(size: 18, weight: .semibold))
                                
                                Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
            .background(
                                ZStack {
                                    // Base gradient
                LinearGradient(
                                        colors: isFormValid ? [Brand.primaryBlue, Brand.lightCoral] : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                                    
                                    // Shimmer effect when valid
                                    if isFormValid && !isLoading {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.3), Color.clear, Color.white.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .offset(x: showSuccessAnimation ? 300 : -300)
                                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: showSuccessAnimation)
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: isFormValid ? Brand.primaryBlue.opacity(0.3) : Color.clear,
                                radius: isFormValid ? 12 : 0,
                                x: 0,
                                y: 6
                            )
                        }
                        .disabled(!isFormValid || isLoading)
                        .scaleEffect(isFormValid ? 1.0 : 0.95)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
                        
                        // Simplified terms
                        HStack(spacing: 8) {
                            Button("Terms of Service") {
                                // Handle terms
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Brand.primaryBlue)
                            
                            Text("•")
                                .font(.system(size: 14))
                                .foregroundColor(Brand.textSecondary)
                            
                            Button("Privacy Policy") {
                                // Handle privacy
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Brand.primaryBlue)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    .opacity(animateFields ? 1.0 : 0.0)
                    .offset(y: animateFields ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(1.4), value: animateFields)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation {
                animateFields = true
            }
            // Start background animation immediately and keep it running
            animateBackground = true
        }
    }
    
    private var isFormValid: Bool {
        let phoneDigits = phoneNumber.filter { $0.isNumber }
        return !firstName.isEmpty && firstName.count >= 2 && 
               !email.isEmpty && email.contains("@") && email.hasSuffix(".edu") &&
               !phoneNumber.isEmpty && phoneDigits.count >= 10
    }
    
    private func handleContinue() {
        isLoading = true
        
        // Success animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSuccessAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Save registration data to store
            store.username = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            store.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
            store.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            
            isLoading = false
            
            // Call completion handler to dismiss onboarding and go to homepage
            onComplete()
        }
    }
}

// MARK: - Enhanced Form Fields

struct EnhancedFirstNameField: View {
    @Binding var firstName: String
    @FocusState private var isFocused: Bool
    @State private var animateIcon = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Brand.primaryBlue)
                    .scaleEffect(animateIcon ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateIcon)
                
                Text("First Name")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Brand.textPrimary)
            }
            
            ZStack {
                // Background with glassmorphism effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: isFocused ? [Brand.primaryBlue, Brand.lightCoral] : [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isFocused ? Brand.primaryBlue.opacity(0.2) : Color.black.opacity(0.05),
                        radius: isFocused ? 8 : 4,
                        x: 0,
                        y: isFocused ? 4 : 2
                    )
                
                TextField("Enter your first name", text: $firstName)
                    .focused($isFocused)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(false)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Brand.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animateIcon = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animateIcon = false
                }
            }
            
            // Validation feedback
            HStack(spacing: 6) {
                Image(systemName: firstName.count >= 2 ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(firstName.count >= 2 ? Brand.emerald : Color.gray.opacity(0.4))
                
                Text(firstName.count >= 2 ? "Looks good!" : "Enter at least 2 characters")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(firstName.count >= 2 ? Brand.emerald : Brand.textSecondary)
            }
            .opacity(firstName.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: firstName.isEmpty)
        }
    }
}

struct EnhancedEmailField: View {
    @Binding var email: String
    @FocusState private var isFocused: Bool
    @State private var animateIcon = false
    
    private var isValid: Bool {
        email.contains("@") && email.hasSuffix(".edu") && !email.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Brand.primaryBlue)
                    .scaleEffect(animateIcon ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateIcon)
                
                Text("Email Address")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Brand.textPrimary)
            }
            
            ZStack {
                // Background with glassmorphism effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: isFocused ? [Brand.primaryBlue, Brand.lightCoral] : [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isFocused ? Brand.primaryBlue.opacity(0.2) : Color.black.opacity(0.05),
                        radius: isFocused ? 8 : 4,
                        x: 0,
                        y: isFocused ? 4 : 2
                    )
                
                TextField("Enter your .edu email", text: $email)
                    .focused($isFocused)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Brand.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animateIcon = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animateIcon = false
                }
            }
            
            // Validation feedback
            HStack(spacing: 6) {
                Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(isValid ? Brand.emerald : Color.gray.opacity(0.4))
                
                Text(isValid ? "Valid .edu email!" : "Must be a .edu email address")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isValid ? Brand.emerald : Brand.textSecondary)
            }
            .opacity(email.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: email.isEmpty)
        }
    }
}

struct EnhancedPhoneNumberField: View {
    @Binding var phoneNumber: String
    @FocusState private var isFocused: Bool
    @State private var animateIcon = false
    
    private var isValid: Bool {
        phoneNumber.filter { $0.isNumber }.count >= 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Brand.primaryBlue)
                    .scaleEffect(animateIcon ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateIcon)
                
                Text("Phone Number")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Brand.textPrimary)
            }
            
            ZStack {
                // Background with glassmorphism effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: isFocused ? [Brand.primaryBlue, Brand.lightCoral] : [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isFocused ? Brand.primaryBlue.opacity(0.2) : Color.black.opacity(0.05),
                        radius: isFocused ? 8 : 4,
                        x: 0,
                        y: isFocused ? 4 : 2
                    )
                
                TextField("123-456-7890", text: $phoneNumber)
                    .focused($isFocused)
                    .keyboardType(.phonePad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Brand.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animateIcon = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animateIcon = false
                }
            }
            .onChange(of: phoneNumber) { newValue in
                // Format phone number with dashes
                let digits = newValue.filter { $0.isNumber }
                if digits.count <= 10 {
                    if digits.count <= 3 {
                        phoneNumber = digits
                    } else if digits.count <= 6 {
                        phoneNumber = "\(digits.prefix(3))-\(digits.dropFirst(3))"
                    } else {
                        phoneNumber = "\(digits.prefix(3))-\(digits.dropFirst(3).prefix(3))-\(digits.dropFirst(6))"
                    }
                }
            }
            
            // Validation feedback
            HStack(spacing: 6) {
                Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(isValid ? Brand.emerald : Color.gray.opacity(0.4))
                
                Text(isValid ? "Phone number looks good!" : "Enter a valid phone number")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isValid ? Brand.emerald : Brand.textSecondary)
            }
            .opacity(phoneNumber.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: phoneNumber.isEmpty)
        }
    }
}

struct PhoneNumberField: View {
    @Binding var phoneNumber: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Phone Number")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("123-456-7890", text: $phoneNumber)
                .focused($isFocused)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? Color.blue.opacity(0.8) : (phoneNumber.count >= 10 ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)), lineWidth: isFocused ? 2 : (phoneNumber.count >= 10 ? 2 : 1))
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
                .onChange(of: phoneNumber) { newValue in
                    // Format phone number with dashes
                    let digits = newValue.filter { $0.isNumber }
                    if digits.count <= 10 {
                        if digits.count <= 3 {
                            phoneNumber = digits
                        } else if digits.count <= 6 {
                            phoneNumber = "\(digits.prefix(3))-\(digits.dropFirst(3))"
                        } else {
                            phoneNumber = "\(digits.prefix(3))-\(digits.dropFirst(3).prefix(3))-\(digits.dropFirst(6))"
                        }
                    }
                }
            
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("We'll use this to verify your account")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FirstNameField: View {
    @Binding var firstName: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("First Name")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("Enter your first name", text: $firstName)
                .focused($isFocused)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(false)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? Color.blue.opacity(0.8) : (firstName.count >= 2 ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)), lineWidth: isFocused ? 2 : (firstName.count >= 2 ? 2 : 1))
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("This will be your display name")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct EmailField: View {
    @Binding var email: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Email Address")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("Enter your .edu email", text: $email)
                .focused($isFocused)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFocused ? Color.blue.opacity(0.8) : (email.contains("@") && email.hasSuffix(".edu") && !email.isEmpty ? Color.green.opacity(0.5) : Color.gray.opacity(0.2)), lineWidth: isFocused ? 2 : (email.contains("@") && email.hasSuffix(".edu") && !email.isEmpty ? 2 : 1))
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            
            HStack(spacing: 8) {
                Image(systemName: "envelope.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("Must be a .edu email address")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct UsernameField: View {
    @Binding var username: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Username")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("Choose a username", text: $username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            
            Text("This will be shown on your profile and leaderboard")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
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
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .font(.headline)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: AppStore
    @State private var currentPage = 0
    @State private var showRegistration = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    title: "Welcome to Alpha",
                    subtitle: "The Duolingo for Finance Technicals",
                    description: "Master investment banking and technical skills through gamified learning.",
                    icon: "graduationcap.fill",
                    color: Color.mint
                )
                .tag(0)
                
                OnboardingPage(
                    title: "Learn by Doing",
                    subtitle: "Interactive Lessons & Cases",
                    description: "Practice with real interview questions, case studies, and technical challenges.",
                    icon: "brain.head.profile",
                    color: .blue
                )
                .tag(1)
                
                OnboardingPage(
                    title: "Track Progress",
                    subtitle: "Gamified Learning Experience",
                    description: "Earn XP, unlock achievements, and compete with others on the leaderboard.",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.orange
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 20) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.mint : .gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // Action controls (plain text style)
                HStack(spacing: 16) {
                    if currentPage < 2 {
                        Text("Skip")
                            .foregroundColor(.secondary)
                            .onTapGesture {
                                dismiss()
                            }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text("Next")
                                .foregroundColor(Brand.textPrimary)
                            Image(systemName: "arrow.right")
                                .foregroundColor(Brand.textPrimary)
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    } else {
                        HStack(spacing: 8) {
                            Text("Get started")
                                .foregroundColor(.black)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showRegistration = true
                            }
                        }
                        .frame(maxWidth: 280)
                    }
                }
                .padding(.horizontal, 32)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(
            LinearGradient(
                colors: [Color.mint.opacity(0.1), .blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        
        }
        .sheet(isPresented: $showRegistration) {
            RegistrationView(onComplete: {
                onComplete() // Call the OnboardingView's completion handler
            })
                .environmentObject(store)
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                    
                    Image(systemName: icon)
                        .font(.system(size: 60))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(color)
                        .multilineTextAlignment(.center)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct AchievementsView: View {
    @EnvironmentObject var store: AppStore
    
    var quickWins: [Achievement] {
        ContentProvider.achievements.filter { achievement in
            achievement.xpReward <= 250
        }
    }
    
    var mediumTerm: [Achievement] {
        ContentProvider.achievements.filter { achievement in
            achievement.xpReward > 250 && achievement.xpReward <= 900
        }
    }
    
    var longTerm: [Achievement] {
        ContentProvider.achievements.filter { achievement in
            achievement.xpReward > 900
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick Wins Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            Text("Quick Wins")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(quickWins) { achievement in
                                AchievementCard(achievement: achievement, isUnlocked: store.achievements.contains(achievement.id))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Medium-Term Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Medium-Term Goals")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(mediumTerm) { achievement in
                                AchievementCard(achievement: achievement, isUnlocked: store.achievements.contains(achievement.id))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Long-Term Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            Text("Long-Term Mastery")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(longTerm) { achievement in
                                AchievementCard(achievement: achievement, isUnlocked: store.achievements.contains(achievement.id))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(.systemGray6))
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.rarity.gradient : LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 35, height: 35)
                
                Image(systemName: achievement.icon)
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .font(.system(size: 16, weight: .medium))
            }
            
            VStack(spacing: 3) {
                Text(achievement.title)
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if isUnlocked {
                    Text("+\(achievement.xpReward) XP")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(width: 100, height: 120)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: Lessons List & Flow

struct LessonsView: View {
    let lessons: [Lesson]
    var startWithFirst: Bool = false
    @EnvironmentObject var store: AppStore
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""
    
    var filteredLessons: [Lesson] {
        let categoryFiltered = selectedCategory == nil ? lessons : lessons.filter { $0.category == selectedCategory }
        return searchText.isEmpty ? categoryFiltered : categoryFiltered.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var categories: [String] {
        Array(Set(lessons.map { $0.category })).sorted()
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Text("Lessons")
                                .font(.system(size: min(32, geometry.size.width * 0.08), weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("Master finance & consulting through interactive lessons")
                                .font(.system(size: min(16, geometry.size.width * 0.04), weight: .semibold))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        // Search and filter bar with glassmorphism
                        GlassmorphismCard(cornerRadius: 20, shadowRadius: 12) {
                            VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                                        .font(.system(size: min(18, geometry.size.width * 0.045)))
                        TextField("Search lessons...", text: $searchText)
                                        .font(.system(size: min(16, geometry.size.width * 0.04)))
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                                .padding(min(12, geometry.size.width * 0.03))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                    )
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                                        ModernCategoryChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                            geometry: geometry,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(categories, id: \.self) { category in
                                            ModernCategoryChip(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                                geometry: geometry,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                            .padding(min(16, geometry.size.width * 0.04))
                        }
                        .padding(.horizontal, 20)
                
                        // Lessons grid with modern cards
                    LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                        ForEach(filteredLessons) { lesson in
                                ModernLessonCard(
                                    lesson: lesson,
                                    isCompleted: store.completedLessonIDs.contains(lesson.id),
                                    geometry: geometry
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                .background(
                    AnimatedGradientBackground(
                        colors: [Color.blue.opacity(0.08), Color.purple.opacity(0.06), Color.mint.opacity(0.04), Color.cyan.opacity(0.02)]
                    )
                )
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct ModernCategoryChip: View {
    let title: String
    let isSelected: Bool
    let geometry: GeometryProxy
    let action: () -> Void
    @State private var appear = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: min(14, geometry.size.width * 0.035), weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, min(16, geometry.size.width * 0.04))
                .padding(.vertical, min(8, geometry.size.width * 0.02))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isSelected ?
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.2)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct ModernLessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    let geometry: GeometryProxy
    @State private var appear = false
    
    var body: some View {
        NavigationLink(destination: LessonPlayView(lesson: lesson)) {
            GlassmorphismCard(cornerRadius: 20, shadowRadius: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    // Header with icon and status
                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                    LinearGradient(
                                        colors: isCompleted ? [.green, .mint] : [lesson.type.color, lesson.type.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                                .frame(width: min(40, geometry.size.width * 0.1), height: min(40, geometry.size.width * 0.1))
                                .shadow(color: lesson.type.color.opacity(0.3), radius: 6, x: 0, y: 3)
                            
                            Image(systemName: isCompleted ? "checkmark" : lesson.type.icon)
                                .font(.system(size: min(16, geometry.size.width * 0.04), weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: min(16, geometry.size.width * 0.04)))
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lesson.title)
                            .font(.system(size: min(14, geometry.size.width * 0.035), weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text(lesson.description)
                            .font(.system(size: min(12, geometry.size.width * 0.03)))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(lesson.type.displayName)
                                .font(.system(size: min(10, geometry.size.width * 0.025), weight: .semibold))
                                .foregroundColor(lesson.type.color)
                            
                            Spacer()
                            
                            Text("\(lesson.xpReward) XP")
                                .font(.system(size: min(10, geometry.size.width * 0.025), weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(min(12, geometry.size.width * 0.03))
            }
        }
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3)), value: appear)
        .onAppear {
            appear = true
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.clear)
                        .background(Material.regularMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? .clear : .secondary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    @State private var animateCard = false
    
    private var strokeColor: Color {
        isCompleted ? .green.opacity(0.3) : lesson.type.color.opacity(0.2)
    }
    
    var body: some View {
        NavigationLink(destination: LessonPlayView(lesson: lesson)) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with type icon and difficulty
                HStack {
                    ZStack {
                        Circle()
                            .fill(lesson.type.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: lesson.type.icon)
                            .foregroundColor(lesson.type.color)
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        DifficultyBadge(difficulty: lesson.difficulty)
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                    }
                }
                
                // Title and description
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(lesson.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.15))
                                )
                        }
                    }
                }
                
                // Footer with XP and time
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(lesson.xpReward) XP")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("\(lesson.estimatedTime)m")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(strokeColor, lineWidth: 1)
                    )
            )
            .scaleEffect(animateCard ? 1.0 : 0.95)
            .opacity(animateCard ? 1.0 : 0.8)
            .animation(.easeOut(duration: 0.3), value: animateCard)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(Double.random(in: 0...0.5))) {
                animateCard = true
            }
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Lesson.Difficulty
    
    private var badgeColor: Color {
        switch difficulty {
        case .beginner:
            return Brand.teal
        case .intermediate:
            return Brand.primaryBlue
        case .advanced:
            return Brand.lavender
        case .expert:
            return Brand.mint
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(Brand.smallFont)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(badgeColor)
            )
    }
}

struct LessonRow: View {
    let lesson: Lesson
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(lesson.title).font(Brand.bodyFont)
                Text(lesson.description).font(Brand.smallFont).foregroundColor(Brand.textSecondary)
            }
            Spacer()
            VStack {
                Text("\(lesson.xpReward) XP").font(Brand.smallFont).foregroundColor(Brand.textSecondary)
                Image(systemName: lesson.type == .flashcards ? "rectangle.stack.fill" : lesson.type == .multipleChoice ? "list.bullet" : "briefcase.fill")
                    .foregroundColor(Brand.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: Lesson Player (Quiz / Flashcard)

struct LessonPlayView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let lesson: Lesson
    @State private var currentIndex: Int = 0
    @State private var score: Int = 0
    @State private var showResults: Bool = false
    @State private var showHint: Bool = false
    @State private var animateQuestion = false
    @State private var showCelebration = false
    @State private var showStreakCelebration = false
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var userAnswers: [Bool] = [] // Track correct/incorrect for each question
    @State private var selectedAnswers: [Int] = [] // Track what the user actually selected
    
    var progress: Double {
        Double(currentIndex) / Double(lesson.questions.count)
    }
    
    var body: some View {
        ZStack {
            // Onboarding-style background gradient
            Brand.onboardingBackgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 16) {
                    HStack {
                        Button("← Back") {
                            dismiss()
                        }
                        .foregroundColor(Brand.teal)
                        
                        Spacer()
                        
                        Text("\(min(currentIndex + 1, lesson.questions.count))/\(lesson.questions.count)")
                            .font(Brand.subheadlineFont)
                            .foregroundColor(Brand.textSecondary)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [lesson.type.color, lesson.type.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 8)
                                .animation(.easeInOut(duration: 0.5), value: progress)
                        }
                    }
                    .frame(height: 8)
                    
                    // Lesson info
                    HStack {
                        Text(lesson.title)
                            .font(.title2.weight(.semibold)) // Smaller than headlineFont
                            .foregroundColor(Brand.textPrimary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 8) {
                                // Points display
                                HStack(spacing: 4) {
                                    Image(systemName: "diamond.fill")
                                        .foregroundColor(Brand.primaryBlue)
                                        .font(.caption)
                                    Text("\(store.pointsEarnedThisSession) pts")
                                        .font(Brand.smallFont)
                                        .foregroundColor(Brand.primaryBlue)
                                }
                                
                                // Streak display
                                if store.currentQuestionStreak > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(Brand.teal)
                                            .font(.caption)
                                        Text("\(store.currentQuestionStreak)")
                                            .font(Brand.smallFont)
                                            .foregroundColor(Brand.teal)
                                    }
                                }
                                
                                // XP display
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Brand.lavender)
                                        .font(.caption)
                                    Text("\(lesson.xpReward) XP")
                                        .font(Brand.smallFont)
                                        .foregroundColor(Brand.lavender)
                                }
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(Brand.textSecondary)
                                    .font(.caption)
                                Text("\(lesson.estimatedTime)m")
                                    .font(Brand.smallFont)
                                    .foregroundColor(Brand.textSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Material.ultraThinMaterial)
                
                // Question content
                if currentIndex < lesson.questions.count {
                    let q = lesson.questions[currentIndex]
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            CardQuestionView(
                                question: q,
                                lessonType: lesson.type,
                                onAnswer: handleAnswer(_:correct:selectedIndex:)
                            )
                            .scaleEffect(animateQuestion ? 1.0 : 0.95)
                            .opacity(animateQuestion ? 1.0 : 0.8)
                            .animation(.easeOut(duration: 0.5), value: animateQuestion)
                            
                            if let hint = q.hint {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showHint.toggle()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(Brand.teal)
                                        Text("Show Hint")
                                            .font(Brand.bodyFont)
                                    }
                                    .foregroundColor(Brand.textPrimary)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Material.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(.yellow.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if showHint {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("💡 Hint")
                                            .font(Brand.subheadlineFont)
                                            .foregroundColor(Brand.teal)
                                        
                                        Text(hint)
                                            .font(Brand.bodyFont)
                                            .foregroundColor(Brand.textPrimary)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.yellow.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.yellow.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .padding(20)
                    }
                } else {
                    // Results screen
                    LessonResultsView(
                        lesson: lesson,
                        score: score,
                        totalQuestions: lesson.questions.count,
                        userAnswers: userAnswers,
                        selectedAnswers: selectedAnswers,
                        onFinish: finish
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            animateQuestion = true
            store.resetSession()
        }
        .onChange(of: currentIndex) { _, _ in
            animateQuestion = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateQuestion = true
            }
        }
        .overlay(
            Group {
                if showCelebration {
                    CelebrationView()
                        .transition(.scale.combined(with: .opacity))
                }
                if showStreakCelebration {
                    StreakCelebrationView(streak: store.currentQuestionStreak)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }

    func handleAnswer(_ question: Question, correct: Bool, selectedIndex: Int) {
        // Track the answer
        userAnswers.append(correct)
        selectedAnswers.append(selectedIndex)
        
        // Mark that user has attempted a question
        store.hasAttemptedQuestion = true
        
        if correct {
            score += 1
            store.handleCorrectAnswer()
            
            // Show celebration for correct answers
            withAnimation(.easeInOut(duration: 0.3)) {
                showCelebration = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCelebration = false
            }
            
            // Show streak celebration for milestones
            if store.currentQuestionStreak == 5 || store.currentQuestionStreak == 10 || store.currentQuestionStreak == 20 || store.currentQuestionStreak == 50 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStreakCelebration = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    showStreakCelebration = false
                }
            }
        } else {
            store.handleIncorrectAnswer()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentIndex += 1
        }
    }

    func finish() {
        let ratio = Double(score) / Double(max(1, lesson.questions.count))
        let earned = Int(Double(lesson.xpReward) * (0.5 + 0.5 * ratio))
        store.awardXP(earned)
        
        // Track study time (estimated based on lesson time)
        store.totalStudyTime += lesson.estimatedTime
        store.updateDailyGoalProgress(action: .studyTime(lesson.estimatedTime))
        
        // Only unlock next road if user scores at least 75%
        if ratio >= 0.75 {
            store.markLessonCompleted(lesson.id)
            // Set flag to show unlock animation on quest page
            store.shouldShowUnlockAnimation = true
        }
        
        if ratio == 1.0 {
            store.perfectLessons += 1
            // Update daily goals for perfect lesson
            store.updateDailyGoalProgress(action: .perfectLesson)
        }
        
        // Navigate back to quest page
        dismiss()
    }
}

struct LessonResultsView: View {
    let lesson: Lesson
    let score: Int
    let totalQuestions: Int
    let userAnswers: [Bool]
    let selectedAnswers: [Int]
    let onFinish: () -> Void
    
    @State private var animateResults = false
    @State private var showXPAnimation = false
    @State private var showReview = false
    
    var percentage: Double {
        Double(score) / Double(totalQuestions)
    }
    
    var earnedXP: Int {
        Int(Double(lesson.xpReward) * (0.5 + 0.5 * percentage))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)
            
            // Results header with better spacing
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.mint.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                    
                    Image(systemName: percentage >= 0.8 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(percentage >= 0.8 ? .green : .orange)
                }
                .scaleEffect(animateResults ? 1.0 : 0.5)
                .opacity(animateResults ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8), value: animateResults)
                
                VStack(spacing: 16) {
                    Text(percentage >= 0.8 ? "Excellent!" : "Good Job!")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("You scored \(score) out of \(totalQuestions)")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .opacity(animateResults ? 1.0 : 0.0)
                .offset(y: animateResults ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: animateResults)
            }
            
            Spacer()
                .frame(height: 40)
            
            // XP indicator with better spacing
            if percentage >= 0.8 {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    
                    Text("+\(earnedXP) XP")
                        .font(.title3.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .opacity(animateResults ? 1.0 : 0.0)
                .offset(y: animateResults ? 0 : 10)
                .animation(.easeOut(duration: 0.8).delay(0.6), value: animateResults)
            }
            
            Spacer()
                .frame(height: 60)
            
            // Action buttons with better spacing
            VStack(spacing: 24) {
                // Continue as plain black text button
                Button(action: onFinish) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.title2.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.title2.weight(.semibold))
                    }
                    .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(animateResults ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(0.9), value: animateResults)
                
                Button("Review") {
                    showReview = true
                }
                .foregroundColor(.blue)
                .font(.title3.weight(.medium))
                .opacity(animateResults ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.8).delay(1.0), value: animateResults)
                
                if percentage < 0.8 {
                    Button("Retry Lesson") {
                        // Handle retry
                    }
                    .foregroundColor(Color.mint)
                    .font(.title3.weight(.medium))
                    .opacity(animateResults ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(1.2), value: animateResults)
                }
            }
            
            Spacer()
                .frame(height: 80)
        }
        .padding(.horizontal, 32)
        .onAppear {
            animateResults = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showXPAnimation = true
            }
        }
        .sheet(isPresented: $showReview) {
            ReviewView(lesson: lesson, userAnswers: userAnswers, selectedAnswers: selectedAnswers)
        }
    }
}

struct ReviewView: View {
    let lesson: Lesson
    let userAnswers: [Bool]
    let selectedAnswers: [Int]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuestionIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Review")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text("Question Review")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Questions list
                    LazyVStack(spacing: 12) {
                        ForEach(Array(lesson.questions.enumerated()), id: \.offset) { index, question in
                            ReviewQuestionRow(
                                questionNumber: index + 1,
                                question: question,
                                isCorrect: index < userAnswers.count ? userAnswers[index] : false,
                                onTap: {
                                    selectedQuestionIndex = index
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: Binding<Bool>(
            get: { selectedQuestionIndex != nil },
            set: { if !$0 { selectedQuestionIndex = nil } }
        )) {
            if let index = selectedQuestionIndex {
                QuestionDetailView(
                    question: lesson.questions[index],
                    questionNumber: index + 1,
                    userSelectedIndex: index < selectedAnswers.count ? selectedAnswers[index] : -1,
                    isCorrect: index < userAnswers.count ? userAnswers[index] : false
                )
            }
        }
    }
}

struct ReviewQuestionRow: View {
    let questionNumber: Int
    let question: Question
    let isCorrect: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Question number
                Text("\(questionNumber)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
                
                // Question text
                VStack(alignment: .leading, spacing: 4) {
                    Text(question.prompt)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let explanation = question.explanation {
                        Text(explanation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Correct/Incorrect indicator
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(isCorrect ? .green : .red)
                
                // Tap indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuestionDetailItem: Identifiable {
    let id: Int
    let index: Int
    
    init(index: Int) {
        self.id = index
        self.index = index
    }
}

struct QuestionDetailView: View {
    let question: Question
    let questionNumber: Int
    let userSelectedIndex: Int
    let isCorrect: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Question \(questionNumber)")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isCorrect ? .green : .red)
                            Text(isCorrect ? "Correct" : "Incorrect")
                                .font(.headline)
                                .foregroundColor(isCorrect ? .green : .red)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Question
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Question:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(question.prompt)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    // Answer choices
                    if !question.choices.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Answer Choices:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(question.choices.enumerated()), id: \.offset) { index, choice in
                                    AnswerChoiceRow(
                                        choice: choice,
                                        index: index,
                                        isUserAnswer: index == userSelectedIndex,
                                        isCorrectAnswer: index == question.correctIndex,
                                        isCorrect: isCorrect
                                    )
                                }
                            }
                        }
                    }
                    
                    // Explanation
                    if let explanation = question.explanation {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Explanation:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(explanation)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
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

struct AnswerChoiceRow: View {
    let choice: String
    let index: Int
    let isUserAnswer: Bool
    let isCorrectAnswer: Bool
    let isCorrect: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Choice letter/number
            Text(String(UnicodeScalar(65 + index)!)) // A, B, C, D
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
            
            // Choice text
            Text(choice)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Status indicators
            HStack(spacing: 8) {
                if isUserAnswer {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                
                if isCorrectAnswer {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(backgroundColor, lineWidth: 2)
                )
        )
    }
    
    private var backgroundColor: Color {
        if isUserAnswer && isCorrectAnswer {
            return .green
        } else if isUserAnswer && !isCorrectAnswer {
            return .red
        } else if isCorrectAnswer {
            return .green
        } else {
            return .gray
        }
    }
}

struct CardQuestionView: View {
    let question: Question
    let lessonType: Lesson.LessonType
    var onAnswer: (_ question: Question, _ correct: Bool, _ selectedIndex: Int) -> Void

    @State private var flipped: Bool = false
    @State private var selectedIndex: Int? = nil
    @State private var showCorrect: Bool = false
    @State private var animateAnswer = false
    @State private var showExplanation = false
    
    private func backgroundFillColor(for index: Int) -> Color {
        if selectedIndex == index {
            if showCorrect {
                return question.correctIndex == index ? .green.opacity(0.1) : .red.opacity(0.1)
            } else {
                return lessonType.color.opacity(0.1)
            }
        } else {
            return .clear
        }
    }
    
    private func strokeColor(for index: Int) -> Color {
        if selectedIndex == index {
            if showCorrect {
                return question.correctIndex == index ? .green : .red
            } else {
                return lessonType.color
            }
        } else {
            return .clear
        }
    }
    
    private func circleFillColor(for index: Int) -> Color {
        if selectedIndex == index {
            if showCorrect {
                return question.correctIndex == index ? .green : .red
            } else {
                return lessonType.color
            }
        } else {
            return .gray.opacity(0.2)
        }
    }
    
    private func circleIconName(for index: Int) -> String {
        if showCorrect {
            return question.correctIndex == index ? "checkmark" : "xmark"
        } else {
            return "circle"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Question card - Elevated design
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lessonType.color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8) // Enhanced shadow for elevation
                    .shadow(color: lessonType.color.opacity(0.2), radius: 12, x: 0, y: 4) // Colored shadow
                
                if lessonType == .flashcards {
                    if !flipped {
                        // Question side
                        VStack(spacing: 16) {
                            HStack {
                                Text("Question")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(lessonType.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(lessonType.color.opacity(0.1))
                                    )
                                Spacer()
                            }
                            
                            Text(question.prompt)
                                .font(.title3.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8)) {
                                    flipped.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Show Answer")
                                        .fontWeight(.medium)
                                    Image(systemName: "arrow.right")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(
                                    LinearGradient(
                                        colors: [lessonType.color, lessonType.color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Answer side
                        VStack(spacing: 16) {
                            HStack {
                                Text("Answer")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.green.opacity(0.1))
                                    )
                                Spacer()
                            }
                            
                            if let hint = question.hint {
                                Text(hint)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                            } else {
                                Text("No hint available")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                onAnswer(question, true, -1)
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Got it!")
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                } else {
                    // Non-flashcard question
                    VStack(spacing: 16) {
                        HStack {
                            Text(lessonType == .multipleChoice ? "Multiple Choice" : "Case Study")
                                .font(.caption.weight(.medium))
                                .foregroundColor(lessonType.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(lessonType.color.opacity(0.1))
                                )
                            Spacer()
                        }
                        
                        Text(question.prompt)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            // Answer options
            if lessonType == .multipleChoice {
                VStack(spacing: 12) {
                    ForEach(Array(question.choices.enumerated()), id: \.offset) { idx, choice in
                        Button(action: {
                            selectedIndex = idx
                            let correct = (idx == question.correctIndex)
                            
                            // Haptic feedback for incorrect answer only
                            if !correct {
                                #if os(iOS)
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                #endif
                            }
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCorrect = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                onAnswer(question, correct, idx)
                                selectedIndex = nil
                                showCorrect = false
                                showExplanation = false
                            }
                            
                            if correct && question.explanation != nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showExplanation = true
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(circleFillColor(for: idx))
                                        .frame(width: 24, height: 24)
                                    
                                    if selectedIndex == idx {
                                        Image(systemName: circleIconName(for: idx))
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Text(choice)
                                    .font(.body.weight(.medium))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(backgroundFillColor(for: idx))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(strokeColor(for: idx), lineWidth: 2)
                                    )
                            )
                        }
                        .disabled(selectedIndex != nil)
                        .scaleEffect(selectedIndex == idx ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                    }
                }
            } else if lessonType == .miniCase || lessonType == .caseStudy {
                VStack(spacing: 16) {
                    Button(action: {
                        onAnswer(question, true, -1)
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .fontWeight(.medium)
                            Text("Submit Answer")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [lessonType.color, lessonType.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: lessonType.color.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Explanation
            if showExplanation, let explanation = question.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Explanation")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.blue)
                    
                    Text(explanation)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.blue.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// MARK: - Unlock Animation View

struct UnlockAnimationView: View {
    let lessonIndex: Int
    let onDismiss: () -> Void
    @State private var lockAppeared = false
    @State private var lockShaking = false
    @State private var lockOpened = false
    @State private var textVisible = false
    @State private var showStars = false
    @State private var starsAnimate = false
    @State private var fadeOutBackground = false
    
    var body: some View {
        ZStack {
            // Enhanced background with blur
            Color.black.opacity(fadeOutBackground ? 0.0 : 0.6)
                .ignoresSafeArea()
                .blur(radius: fadeOutBackground ? 0 : 2)
                .animation(.easeOut(duration: 0.8), value: fadeOutBackground)
            
            VStack(spacing: 40) {
                // Styled lock animation
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(lockAppeared ? 1.0 : 0.8)
                        .opacity(lockAppeared ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8), value: lockAppeared)
                    
                    // Lock icon with enhanced styling
                    Image(systemName: lockOpened ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        .scaleEffect(lockAppeared ? 1.0 : 0.7)
                        .offset(x: lockShaking ? 3 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: lockAppeared)
                        .animation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true), value: lockShaking)
                        .animation(.easeOut(duration: 0.4), value: lockOpened)
                }
                .opacity(showStars ? 0.0 : 1.0)
                .animation(.easeOut(duration: 0.5), value: showStars)
                
                // Clean unlock text
                VStack(spacing: 8) {
                    Text("Level Unlocked!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                }
                .opacity(textVisible ? 1.0 : 0.0)
                .offset(y: textVisible ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: textVisible)
                .opacity(showStars ? 0.0 : 1.0)
                .animation(.easeOut(duration: 0.5), value: showStars)
            }
            
            // Star celebration animation (same as CelebrationView)
            if showStars {
                ZStack {
                    ForEach(0..<20, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                            .offset(
                                x: CGFloat.random(in: -200...200),
                                y: CGFloat.random(in: -400...0)
                            )
                            .scaleEffect(starsAnimate ? 1.5 : 0.5)
                            .opacity(starsAnimate ? 0 : 1)
                            .animation(
                                .easeOut(duration: 2.0)
                                .delay(Double.random(in: 0...1)),
                                value: starsAnimate
                            )
                    }
                }
                .opacity(starsAnimate ? 0.0 : 1.0)
                .animation(.easeOut(duration: 0.5).delay(1.5), value: starsAnimate)
                .onAppear {
                    starsAnimate = true
                }
            }
        }
        .onAppear {
            // Start animation sequence
            lockAppeared = true
            
            // Lock shaking (anticipation)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                lockShaking = true
            }
            
            // Lock opens
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                lockOpened = true
            }
            
            // Text appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                textVisible = true
            }
            
            // Hide lock and text, show stars
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                showStars = true
            }
            
            // Start background fade out before dismissing
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                fadeOutBackground = true
            }
            
            // Auto-dismiss after background fades out
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                onDismiss()
            }
        }
    }
}

