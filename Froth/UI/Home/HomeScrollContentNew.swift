import SwiftUI
import Combine

struct HomeScrollContentNew: View {
    @ObservedObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    @Binding var animateProgress: Bool
    @Binding var pulseAnimation: Bool
    @Binding var animateHeader: Bool
    
    @State private var animateElements = false
    @State private var floatingOffset: CGFloat = 0
    @State private var animateGradient = false
    @State private var showParticles = false
    @State private var cardAnimations: [Bool] = Array(repeating: false, count: 6)
    
    var body: some View {
        ZStack {
            // Onboarding-style background gradient (matching welcome screen)
            Brand.onboardingBackgroundGradient
                .ignoresSafeArea(.all)
            
            // Enhanced stunning background with multiple layers
            StunningEnhancedBackground()
                .ignoresSafeArea(.all)
            
            ScrollView {
                LazyVStack(spacing: 13) {
                        // Hero Welcome Section
                        HeroWelcomeSection(
                            store: store,
                            animateHeader: animateHeader,
                            animateElements: animateElements
                        )
                        
                        // Progress Overview Card
                        ProgressOverviewCard(
                            store: store,
                            animateProgress: animateProgress,
                            pulseAnimation: pulseAnimation,
                            cardIndex: 0,
                            cardAnimations: $cardAnimations
                        )
                        .padding(.top, -6)
                        
                        // Quick Actions Grid
                        QuickActionsGrid(
                            store: store,
                            pendingLesson: $pendingLesson,
                            navigateToLesson: $navigateToLesson,
                            cardIndex: 1,
                            cardAnimations: $cardAnimations
                        )
                        .padding(.top, -6)
                        
                        // Bottom padding
                        Spacer()
                            .frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, -28)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Staggered card animations
        for i in 0..<cardAnimations.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    cardAnimations[i] = true
                }
            }
        }
        
        // Other animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.8)) {
                animateElements = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 1.2)) {
                animateGradient = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                showParticles = true
            }
        }
    }
}

// MARK: - Hero Welcome Section

struct HeroWelcomeSection: View {
    @ObservedObject var store: AppStore
    let animateHeader: Bool
    let animateElements: Bool
    
    private var dynamicGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Hey"
        }
    }
    
    private var userInitials: String {
        let components = store.username.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        } else {
            return String(store.username.prefix(2)).uppercased()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header content without background
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(dynamicGreeting) \(store.username)!")
                            .font(Brand.subheadlineFont)
                            .foregroundColor(Brand.textPrimary)
                            .scaleEffect(animateHeader ? 1.0 : 0.9)
                            .opacity(animateHeader ? 1.0 : 0.7)
                        
                        Text("Ready to level up your finance skills?")
                            .font(Brand.smallFont)
                            .foregroundColor(Brand.textSecondary)
                            .scaleEffect(animateHeader ? 1.0 : 0.9)
                            .opacity(animateHeader ? 1.0 : 0.7)
                    }
                    
                    Spacer()
                    
                    // User avatar/initials bubble
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Brand.primaryBlue.opacity(0.2),
                                        Brand.primaryBlue.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Brand.primaryBlue.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(userInitials)
                            .font(Brand.captionFont)
                            .fontWeight(.bold)
                            .foregroundColor(Brand.textPrimary)
                    }
                    .scaleEffect(animateHeader ? 1.0 : 0.8)
                    .opacity(animateHeader ? 1.0 : 0.7)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .frame(height: 100)
        }
    }
}

// MARK: - Stunning Progress Overview Card

struct ProgressOverviewCard: View {
    @ObservedObject var store: AppStore
    let animateProgress: Bool
    let pulseAnimation: Bool
    let cardIndex: Int
    @Binding var cardAnimations: [Bool]
    @State private var localAnimateProgress = false
    @State private var localPulseAnimation = false
    @State private var shimmerOffset: CGFloat = -1.0
    @State private var floatingParticles: [Bool] = Array(repeating: false, count: 8)
    @State private var progressAnimation: Double = 0
    @State private var glowAnimation: Bool = false
    @State private var statHoverStates: [Bool] = Array(repeating: false, count: 3)
    @State private var gradientShift: CGFloat = 0
    @State private var statColumnWidth: CGFloat = 0
    
    private var progressToNext: Double {
        min(1.0, Double(store.xp % 100) / 100.0)
    }
    
    private var progressColor: Color {
        // Use consistent gamification accent color for all progress levels
        return Brand.gamificationAccent
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.gamificationAccent, Brand.lightCoral, Brand.primaryBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // Floating background particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                progressColor.opacity(0.1),
                                progressColor.opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: CGFloat.random(in: 8...16))
                    .offset(
                        x: floatingParticles[index] ? CGFloat.random(in: -50...50) : CGFloat.random(in: -30...30),
                        y: floatingParticles[index] ? CGFloat.random(in: -30...30) : CGFloat.random(in: -20...20)
                    )
                    .opacity(floatingParticles[index] ? 0.8 : 0.3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: floatingParticles[index]
                    )
            }
            
            // Main card with enhanced glassmorphism
            VStack(spacing: 20) {
                // Header with animated level badge
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Progress")
                            .font(Brand.headlineFont)
                            .foregroundColor(Brand.textPrimary)
                        
                        Text("Keep the grind up!")
                            .font(Brand.smallFont)
                            .foregroundColor(Brand.textSecondary)
                    }
                    
                    Spacer()
                    
                // Animated level badge with cohesive gradient
                ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Brand.gamificationAccent.opacity(0.7),
                                        Brand.lightCoral.opacity(0.6),
                                        Brand.primaryBlue.opacity(0.5),
                                        Brand.softBlue.opacity(0.4)
                                    ],
                                    startPoint: UnitPoint(x: (gradientShift.truncatingRemainder(dividingBy: 1.0)), y: 0),
                                    endPoint: UnitPoint(x: (gradientShift.truncatingRemainder(dividingBy: 1.0)) + 0.6, y: 1)
                                )
                            )
                            .frame(width: 80, height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.8),
                                                Brand.gamificationAccent.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: Brand.gamificationAccent.opacity(0.2), radius: glowAnimation ? 8 : 4, x: 0, y: 2)
                            .scaleEffect(glowAnimation ? 1.03 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowAnimation)
                            .animation(.linear(duration: 10.0).repeatForever(autoreverses: false), value: gradientShift)
                        
                        Text("Level \(store.level)")
                            .font(Brand.captionFont)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                }
                
                HStack(spacing: 24) {
                    // Stunning 3D Progress Ring
                    ZStack {
                        // Outer glow ring
                        Circle()
                            .stroke(
                                RadialGradient(
                                    colors: [
                                        progressColor.opacity(0.3),
                                        progressColor.opacity(0.1),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 70
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 140, height: 140)
                            .blur(radius: 4)
                            .scaleEffect(localPulseAnimation ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: localPulseAnimation)
                        
                        // Background ring with subtle gradient
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.15),
                                        Color.gray.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 12
                            )
                            .frame(width: 120, height: 120)
                        
                        // Progress ring with teal gradient
                        Circle()
                            .trim(from: 0, to: progressAnimation)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Brand.gamificationAccent,
                                        Brand.lightCoral,
                                        Brand.primaryBlue.opacity(0.8),
                                        Brand.softBlue.opacity(0.6)
                                    ]),
                                    center: .center,
                                    startAngle: .degrees(-90),
                                    endAngle: .degrees(270)
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: progressColor.opacity(0.4), radius: 8, x: 0, y: 4)
                            .animation(.easeInOut(duration: 2.0), value: progressAnimation)
                        
                        // Inner content with depth
                        VStack(spacing: 6) {
                            Text("\(Int(progressToNext * 100))%")
                                .font(Brand.headlineFont)
                                .fontWeight(.semibold)
                                .foregroundColor(Brand.textPrimary)
                                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                            
                            Text("to next level")
                                .font(Brand.smallFont)
                                .foregroundColor(Brand.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .scaleEffect(localPulseAnimation ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: localPulseAnimation)
                    }
                    .offset(x: 22)
                    
                    Spacer()
                    
                    // Compact Statistics with micro-interactions
                    VStack(alignment: .trailing, spacing: 8) {
                        CompactStatRow(
                            icon: "star.fill",
                            title: "Total XP",
                            value: "\(store.xp)",
                            color: Brand.gold,
                            isHovered: $statHoverStates[0],
                            index: 0,
                            measuredWidth: $statColumnWidth,
                            isReference: false
                        )
                        
                        CompactStatRow(
                            icon: "flame.fill",
                            title: "Day Streak",
                            value: "\(store.streakDays)",
                            color: Brand.gamificationAccent,
                            isHovered: $statHoverStates[1],
                            index: 1,
                            measuredWidth: $statColumnWidth,
                            isReference: true
                        )
                        
                        CompactStatRow(
                            icon: "checkmark.seal.fill",
                            title: "Perfect Lessons",
                            value: "\(store.perfectLessons)",
                            color: Brand.emerald,
                            isHovered: $statHoverStates[2],
                            index: 2,
                            measuredWidth: $statColumnWidth,
                            isReference: false
                        )
                    }
                }
            }
            .padding(20)
            .background(
                ZStack {
                    // Vibrant glassmorphism background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Brand.lightBlue.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.8),
                                            progressColor.opacity(0.2),
                                            Color.white.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    // Animated shimmer effect
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: UnitPoint(x: shimmerOffset, y: 0),
                                endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 1)
                            )
                        )
                        .animation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                    
                    // Subtle inner glow
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            RadialGradient(
                                colors: [
                                    progressColor.opacity(0.08),
                                    progressColor.opacity(0.03),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                }
                .shadow(color: .black.opacity(0.08), radius: 30, x: 0, y: 15)
                .shadow(color: progressColor.opacity(0.1), radius: 20, x: 0, y: 10)
            )
        }
        .scaleEffect(cardAnimations[cardIndex] ? 1.0 : 0.9)
        .opacity(cardAnimations[cardIndex] ? 1.0 : 0.0)
        .offset(y: cardAnimations[cardIndex] ? 0 : 30)
        .onAppear {
            localAnimateProgress = true
            localPulseAnimation = true
            glowAnimation = true
            
            // Animate gradient shift continuously without snapping
            // Use a very long, linear animation and wrap with modulo in startPoint/endPoint usage
            withAnimation(.linear(duration: 60.0).repeatForever(autoreverses: false)) {
                gradientShift = 10.0
            }
            
            // Animate progress ring
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 2.0)) {
                    progressAnimation = progressToNext
                }
            }
            
            // Start floating particles
            for i in 0..<floatingParticles.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                    floatingParticles[i] = true
                }
            }
            
            // Start shimmer animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                shimmerOffset = 1.0
            }
        }
    }
}

// MARK: - Compact Statistics Row (Much Smaller)

struct CompactStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Binding var isHovered: Bool
    let index: Int
    @Binding var measuredWidth: CGFloat
    let isReference: Bool
    
    @State private var iconScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.0
    
    var body: some View {
        HStack(spacing: 10) {
            // Compact icon with subtle glow
            ZStack {
                // Subtle glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(glowIntensity * 0.2),
                                color.opacity(glowIntensity * 0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 30, height: 30)
                    .blur(radius: 2)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isHovered)
                
                // Compact icon container
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.12),
                                color.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.3),
                                        color.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .scaleEffect(iconScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: iconScale)
                
                // Compact icon
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            
            // Compact text content (right-aligned per request)
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(Brand.subheadlineFont)
                    .fontWeight(.bold)
                    .foregroundColor(Brand.textPrimary)
                
                Text(title)
                    .font(Brand.smallFont)
                    .foregroundColor(Brand.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        // Fix width and height before background so background matches tile size
        .frame(width: measuredWidth > 0 ? measuredWidth : nil, height: 68, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isHovered ? 0.7 : 0.5),
                            color.opacity(isHovered ? 0.08 : 0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(isHovered ? 0.35 : 0.22),
                                    color.opacity(isHovered ? 0.20 : 0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(
            color: color.opacity(isHovered ? 0.15 : 0.08),
            radius: isHovered ? 8 : 4,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        if isReference {
                            measuredWidth = geo.size.width
                        }
                    }
                    .onChange(of: geo.size.width) { newValue in
                        if isReference {
                            measuredWidth = newValue
                        }
                    }
            }
        )
        .onTapGesture {
            // Micro-interaction feedback
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                iconScale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    iconScale = 1.0
                }
            }
        }
        .onAppear {
            // Staggered animation based on index
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    glowIntensity = 1.0
                }
            }
        }
        // Height already enforced above
    }
}

// MARK: - Enhanced Statistics Row with Micro-interactions (Legacy)

struct EnhancedStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Binding var isHovered: Bool
    let index: Int
    
    @State private var iconScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.0
    @State private var bounceAnimation: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon with glow and animation
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(glowIntensity * 0.3),
                                color.opacity(glowIntensity * 0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .blur(radius: 3)
                    .scaleEffect(isHovered ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isHovered)
                
                // Icon container
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.15),
                                color.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.4),
                                        color.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .scaleEffect(iconScale)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: iconScale)
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
                    .scaleEffect(bounceAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: bounceAnimation)
            }
            
            // Enhanced text content
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(Brand.headlineFont)
                    .fontWeight(.bold)
                    .foregroundColor(Brand.textPrimary)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                Text(title)
                    .font(Brand.captionFont)
                    .foregroundColor(Brand.textSecondary)
                    .multilineTextAlignment(.trailing)
            }
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isHovered)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isHovered ? 0.8 : 0.6),
                            color.opacity(isHovered ? 0.1 : 0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    color.opacity(isHovered ? 0.3 : 0.15),
                                    color.opacity(isHovered ? 0.15 : 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: color.opacity(isHovered ? 0.2 : 0.1),
            radius: isHovered ? 12 : 6,
            x: 0,
            y: isHovered ? 6 : 3
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
        .onTapGesture {
            // Micro-interaction feedback
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                iconScale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    iconScale = 1.0
                }
            }
        }
        .onAppear {
            // Staggered animation based on index
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    glowIntensity = 1.0
                }
                bounceAnimation = true
            }
        }
    }
}

// Legacy StatRow for compatibility
struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(Brand.subheadlineFont)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(Brand.subheadlineFont)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGrid: View {
    @ObservedObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    let cardIndex: Int
    @Binding var cardAnimations: [Bool]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                AdaptivePrimaryCTACard(
                    store: store,
                    pendingLesson: $pendingLesson,
                    navigateToLesson: $navigateToLesson
                )
                
                QuickActionCard(
                    title: "Daily Goals",
                    subtitle: "Stay consistent",
                    icon: "target",
                    gradient: Brand.secondaryGradient,
                    action: {
                        // TODO: Implement daily goal
                    }
                )
            }
        }
        .scaleEffect(cardAnimations[cardIndex] ? 1.0 : 0.9)
        .opacity(cardAnimations[cardIndex] ? 1.0 : 0.0)
        .offset(y: cardAnimations[cardIndex] ? 0 : 30)
    }
}

struct AdaptivePrimaryCTACard: View {
    @ObservedObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    @State private var isPressed = false
    @State private var hoverEffect = false
    @State private var borderAnimation = false
    @State private var pulseAnimation = false
    
    private var isNewUser: Bool {
        store.xp == 0 && store.streakDays == 0
    }
    
    private var title: String {
        isNewUser ? "Start Learning" : "Continue Learning"
    }
    
    private var subtitle: String {
        isNewUser ? "Begin your journey" : "Resume your journey"
    }
    
    private var borderColor: Color {
        Brand.primaryBlue
    }
    
    var body: some View {
        Button(action: {
            if let next = store.getNextLesson() ?? ContentProvider.sampleLessons.first {
                pendingLesson = next
                DispatchQueue.main.async { navigateToLesson = true }
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    // Enhanced gradient background with pulse animation
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Brand.lightCoral,
                                    Brand.primaryBlue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .saturation(1.2)
                        .brightness(0.06)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 25
                                    )
                                )
                        )
                        .shadow(color: borderColor.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: borderColor.opacity(0.2), radius: 4, x: 0, y: 2)
                        .scaleEffect(hoverEffect ? 1.05 : 1.0)
                        .scaleEffect(pulseAnimation ? 1.08 : 1.0) // Pulse animation
                        .animation(.easeInOut(duration: 0.3), value: hoverEffect)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(Brand.bodyFont)
                        .foregroundColor(Brand.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(Brand.smallFont)
                        .foregroundColor(Brand.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.5), lineWidth: 1.5)
                        )
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onHover { hovering in
            hoverEffect = hovering
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                borderAnimation = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let action: () -> Void
    @State private var isPressed = false
    @State private var hoverEffect = false
    @State private var borderAnimation = false
    
    // Get warm professional border based on card type
    private var borderColor: Color { .black }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    // Enhanced gradient background with subtle animation
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Brand.lightCoral,
                                    Brand.primaryBlue
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .saturation(1.2)
                        .brightness(0.06)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 25
                                    )
                                )
                        )
                        .shadow(color: borderColor.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: borderColor.opacity(0.2), radius: 4, x: 0, y: 2)
                        .scaleEffect(hoverEffect ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: hoverEffect)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(Brand.bodyFont)
                        .foregroundColor(Brand.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(Brand.smallFont)
                        .foregroundColor(Brand.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.5), lineWidth: 1.5)
                        )
                    
                    // Animated colorful inner glow
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                    
                    // Subtle shimmer effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onHover { hovering in
            hoverEffect = hovering
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                borderAnimation = true
            }
        }
    }
}

// MARK: - Learning Statistics Section

struct LearningStatisticsSection: View {
    @ObservedObject var store: AppStore
    let cardIndex: Int
    @Binding var cardAnimations: [Bool]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Analytics")
                .font(Brand.headlineFont)
                .foregroundColor(Brand.textPrimary)
                .padding(.horizontal, 4)
            
            HStack(spacing: 16) {
                HomeStatCard(
                    title: "Weekly Goal",
                    value: "5",
                    subtitle: "Lessons",
                    icon: "target",
                    color: Brand.gentlePurple,
                    progress: 0.8
                )
                
                HomeStatCard(
                    title: "Accuracy",
                    value: "87%",
                    subtitle: "Average",
                    icon: "brain.head.profile",
                    color: Brand.lightPink,
                    progress: 0.87
                )
            }
        }
        .scaleEffect(cardAnimations[cardIndex] ? 1.0 : 0.9)
        .opacity(cardAnimations[cardIndex] ? 1.0 : 0.0)
        .offset(y: cardAnimations[cardIndex] ? 0 : 30)
    }
}

struct HomeStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        FuturisticGlassmorphismCard {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 4) {
                    Text(value)
                        .font(Brand.largeTitleFont)
                        .foregroundColor(Brand.textPrimary)
                    
                    Text(title)
                        .font(Brand.captionFont)
                        .foregroundColor(Brand.textPrimary)
                    
                    Text(subtitle)
                        .font(Brand.smallFont)
                        .foregroundColor(Brand.textSecondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.easeInOut(duration: 1.0), value: progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
        }
    }
}

// MARK: - Achievements and News Section

struct AchievementsAndNewsSection: View {
    @ObservedObject var store: AppStore
    let cardIndex: Int
    @Binding var cardAnimations: [Bool]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Recent Achievements
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Achievements")
                    .font(Brand.subheadlineFont)
                    .foregroundColor(Brand.textPrimary)
                
                VStack(spacing: 12) {
                    AchievementRow(icon: "star.fill", text: "First Perfect Score", color: Brand.softYellow)
                    AchievementRow(icon: "flame.fill", text: "7 Day Streak", color: Brand.warmCoral)
                    AchievementRow(icon: "trophy.fill", text: "Module Master", color: Brand.gentlePurple)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Brand.glassmorphismBorder, lineWidth: 1)
                    )
            )
            
            // Daily Market News
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Brand.accentGradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Daily Market News")
                    .font(Brand.bodyFont)
                    .foregroundColor(Brand.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("S&P 500 up 0.8% on Fed optimism • GDP growth revised to 2.1% • Tech stocks lead gains")
                    .font(Brand.smallFont)
                    .foregroundColor(Brand.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Brand.glassmorphismBorder, lineWidth: 1)
                    )
            )
        }
        .scaleEffect(cardAnimations[cardIndex] ? 1.0 : 0.9)
        .opacity(cardAnimations[cardIndex] ? 1.0 : 0.0)
        .offset(y: cardAnimations[cardIndex] ? 0 : 30)
    }
}

struct AchievementRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(text)
                .font(Brand.captionFont)
                .foregroundColor(Brand.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Daily Streak Card

struct DailyStreakCard: View {
    @ObservedObject var store: AppStore
    let cardIndex: Int
    @Binding var cardAnimations: [Bool]
    @State private var flameAnimation = false
    
    var body: some View {
        FuturisticGlassmorphismCard {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Brand.warmCoralGradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: Brand.warmCoral.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(flameAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: flameAnimation)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(store.streakDays) Day Streak")
                        .font(Brand.largeTitleFont)
                        .foregroundColor(Brand.textPrimary)
                    
                    Text("Keep the momentum going! 🔥")
                        .font(Brand.captionFont)
                        .foregroundColor(Brand.textSecondary)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .scaleEffect(cardAnimations[cardIndex] ? 1.0 : 0.9)
        .opacity(cardAnimations[cardIndex] ? 1.0 : 0.0)
        .offset(y: cardAnimations[cardIndex] ? 0 : 30)
        .onAppear {
            flameAnimation = true
        }
    }
}

// MARK: - Continue Learning Card

struct HomeContinueLearningCard: View {
    let lesson: Lesson
    @ObservedObject var store: AppStore
    @Binding var pendingLesson: Lesson?
    @Binding var navigateToLesson: Bool
    let cardIndex: Int
    @Binding var cardAnimations: [Bool]
    @State private var localPulseAnimation = false
    
    var body: some View {
        FuturisticGlassmorphismCard {
            VStack(spacing: 20) {
                HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Continue Learning")
                        .font(Brand.subheadlineFont)
                        .foregroundColor(Brand.textPrimary)
                    
                    Text(lesson.title)
                        .font(Brand.bodyFont)
                        .foregroundColor(Brand.textPrimary)
                        .lineLimit(2)
                    
                    Text(lesson.description)
                        .font(Brand.captionFont)
                        .foregroundColor(Brand.textSecondary)
                        .lineLimit(2)
                }
                    
                    Spacer()
                    
                    Button(action: {
                        pendingLesson = lesson
                        DispatchQueue.main.async { navigateToLesson = true }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Brand.accentGradient)
                                .frame(width: 50, height: 50)
                                .scaleEffect(localPulseAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: localPulseAnimation)
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack(spacing: 16) {
                    LessonInfoChip(icon: "clock", text: "\(lesson.estimatedTime) min", color: Brand.primaryBlue)
                    LessonInfoChip(icon: "star.fill", text: "\(lesson.xpReward) XP", color: Brand.teal)
                    LessonInfoChip(icon: "chart.bar.fill", text: lesson.difficulty.rawValue, color: Brand.lavender)
                }
            }
            .padding(24)
        }
        .scaleEffect(cardAnimations[cardIndex] ? 1.0 : 0.9)
        .opacity(cardAnimations[cardIndex] ? 1.0 : 0.0)
        .offset(y: cardAnimations[cardIndex] ? 0 : 30)
        .onAppear {
            localPulseAnimation = true
        }
    }
}

struct LessonInfoChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            
            Text(text)
                .font(Brand.smallFont)
                .foregroundColor(Brand.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Enhanced Sophisticated Glassmorphism Card

struct FuturisticGlassmorphismCard<Content: View>: View {
    let content: Content
    @State private var shimmerOffset: CGFloat = -1.0
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    // Base glassmorphism background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Brand.lightBlue.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Brand.glassmorphismBorder.opacity(0.8),
                                            Brand.glassmorphismBorder.opacity(0.4),
                                            Brand.glassmorphismBorder.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Subtle shimmer effect
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: UnitPoint(x: shimmerOffset, y: 0),
                                endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 1)
                            )
                        )
                        .animation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: false),
                            value: shimmerOffset
                        )
                }
                .shadow(color: .black.opacity(0.08), radius: 25, x: 0, y: 12)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .onAppear {
                shimmerOffset = 1.0
            }
    }
}

// MARK: - Stunning Moving Gradient Background

struct StunningMovingGradientBackground: View {
    @State private var animate: Bool = false
    @State private var particleOffset: CGFloat = 0
    @State private var gradientOffset: CGFloat = 0
    @State private var secondaryGradientOffset: CGFloat = 0
    @State private var tertiaryGradientOffset: CGFloat = 0
    @State private var splashAnimations: [Bool] = Array(repeating: false, count: 15)
    
    var body: some View {
        ZStack {
            // Base gradient - sophisticated multi-layer foundation
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.99, blue: 1.0), // Soft white-blue
                    Color(red: 0.96, green: 0.98, blue: 0.99), // Gentle transition
                    Color(red: 0.94, green: 0.96, blue: 0.98), // Subtle depth
                    Color(red: 0.92, green: 0.94, blue: 0.96)  // Warm undertone
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Primary moving gradient - sophisticated wave motion
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.94, blue: 0.98).opacity(0.5),
                    Color(red: 0.87, green: 0.91, blue: 0.96).opacity(0.4),
                    Color(red: 0.84, green: 0.88, blue: 0.94).opacity(0.3),
                    Color(red: 0.82, green: 0.86, blue: 0.92).opacity(0.2)
                ],
                startPoint: UnitPoint(x: gradientOffset, y: 0),
                endPoint: UnitPoint(x: gradientOffset + 0.6, y: 1)
            )
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 14).repeatForever(autoreverses: false), value: gradientOffset)
            
            // Secondary gradient - counter-rotating for depth
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.90, blue: 0.94).opacity(0.3),
                    Color(red: 0.90, green: 0.88, blue: 0.92).opacity(0.2),
                    Color(red: 0.88, green: 0.86, blue: 0.90).opacity(0.15)
                ],
                startPoint: UnitPoint(x: 1 - secondaryGradientOffset, y: 0),
                endPoint: UnitPoint(x: 1 - secondaryGradientOffset - 0.4, y: 1)
            )
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 18).repeatForever(autoreverses: false), value: secondaryGradientOffset)
            
            // Tertiary gradient - diagonal movement for complexity
            LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.92, blue: 0.90).opacity(0.2),
                    Color(red: 0.86, green: 0.90, blue: 0.88).opacity(0.15),
                    Color(red: 0.84, green: 0.88, blue: 0.86).opacity(0.1)
                ],
                startPoint: UnitPoint(x: tertiaryGradientOffset, y: tertiaryGradientOffset),
                endPoint: UnitPoint(x: tertiaryGradientOffset + 0.5, y: tertiaryGradientOffset + 0.5)
            )
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 22).repeatForever(autoreverses: false), value: tertiaryGradientOffset)
            
            // Sophisticated color splashes - organic floating shapes with subtle colors
            ForEach(0..<15, id: \.self) { index in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                subtleColors[index % subtleColors.count].opacity(0.12),
                                subtleColors[index % subtleColors.count].opacity(0.06),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(
                        width: CGFloat(Double.random(in: 220...450)),
                        height: CGFloat(Double.random(in: 180...350))
                    )
                    .offset(
                        x: sin(particleOffset + Double(index) * 0.7) * 180,
                        y: cos(particleOffset + Double(index) * 0.5) * 120
                    )
                    .blur(radius: 4)
                    .animation(
                        .easeInOut(duration: Double.random(in: 15...25))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...5)),
                        value: particleOffset
                    )
            }
            
            // Additional subtle floating elements with gentle colors
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                gentleColors[index % gentleColors.count].opacity(0.08),
                                gentleColors[index % gentleColors.count].opacity(0.03),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: CGFloat(Double.random(in: 100...200)))
                    .offset(
                        x: cos(particleOffset * 0.6 + Double(index) * 1.1) * 250,
                        y: sin(particleOffset * 0.4 + Double(index) * 0.8) * 150
                    )
                    .blur(radius: 3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 18...28))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...7)),
                        value: particleOffset
                    )
            }
            
            // Subtle accent particles for extra visual interest
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                accentColors[index % accentColors.count].opacity(0.06),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: CGFloat(Double.random(in: 60...120)))
                    .offset(
                        x: sin(particleOffset * 0.8 + Double(index) * 1.5) * 300,
                        y: cos(particleOffset * 0.3 + Double(index) * 1.2) * 180
                    )
                    .blur(radius: 2)
                    .animation(
                        .easeInOut(duration: Double.random(in: 20...30))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...8)),
                        value: particleOffset
                    )
            }
        }
        .onAppear {
            animate = true
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                particleOffset = .pi * 2
            }
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                gradientOffset = 1.0
            }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                secondaryGradientOffset = 1.0
            }
            withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                tertiaryGradientOffset = 1.0
            }
        }
    }
    
    // Subtle, sophisticated color palette - not too bright
    private let subtleColors: [Color] = [
        Color(red: 0.80, green: 0.84, blue: 0.88), // Soft blue-gray
        Color(red: 0.84, green: 0.80, blue: 0.84), // Muted purple-gray
        Color(red: 0.88, green: 0.84, blue: 0.80), // Warm beige-gray
        Color(red: 0.82, green: 0.87, blue: 0.84), // Soft green-gray
        Color(red: 0.87, green: 0.82, blue: 0.84), // Gentle pink-gray
        Color(red: 0.84, green: 0.87, blue: 0.80), // Subtle yellow-gray
        Color(red: 0.80, green: 0.87, blue: 0.84), // Cool mint-gray
        Color(red: 0.87, green: 0.80, blue: 0.87), // Soft lavender-gray
        Color(red: 0.82, green: 0.82, blue: 0.87), // Neutral blue-gray
        Color(red: 0.87, green: 0.84, blue: 0.82), // Warm gray
        Color(red: 0.84, green: 0.87, blue: 0.87), // Cool gray
        Color(red: 0.82, green: 0.84, blue: 0.82), // Balanced gray
        Color(red: 0.85, green: 0.83, blue: 0.86), // Gentle violet-gray
        Color(red: 0.83, green: 0.86, blue: 0.83), // Soft sage-gray
        Color(red: 0.86, green: 0.83, blue: 0.85)   // Warm rose-gray
    ]
    
    private let gentleColors: [Color] = [
        Color(red: 0.75, green: 0.80, blue: 0.85), // Gentle blue
        Color(red: 0.80, green: 0.75, blue: 0.80), // Soft purple
        Color(red: 0.85, green: 0.80, blue: 0.75), // Warm beige
        Color(red: 0.78, green: 0.83, blue: 0.80), // Soft green
        Color(red: 0.83, green: 0.78, blue: 0.80), // Gentle pink
        Color(red: 0.80, green: 0.83, blue: 0.76), // Subtle yellow
        Color(red: 0.76, green: 0.83, blue: 0.80), // Cool mint
        Color(red: 0.83, green: 0.76, blue: 0.83)  // Soft lavender
    ]
    
    private let accentColors: [Color] = [
        Brand.primaryBlue.opacity(0.3),
        Brand.teal.opacity(0.3),
        Brand.lavender.opacity(0.3),
        Brand.softGreen.opacity(0.3),
        Brand.warmCoral.opacity(0.3),
        Brand.gentlePurple.opacity(0.3)
    ]
}

// MARK: - Colorful Moving Stars Background

struct ColorfulStarsBackground: View {
    @State private var animationOffset: CGFloat = 0
    @State private var twinkleAnimation: CGFloat = 0
    
    private let starColors: [Color] = [
        Color.blue.opacity(0.8),
        Color.purple.opacity(0.8),
        Color.pink.opacity(0.8),
        Color.cyan.opacity(0.8),
        Color.mint.opacity(0.8),
        Color.yellow.opacity(0.8),
        Color.orange.opacity(0.8),
        Color.red.opacity(0.8)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Multiple layers of moving stars
                ForEach(0..<3, id: \.self) { layer in
                    ForEach(0..<25, id: \.self) { index in
                        StarView(
                            color: starColors[index % starColors.count],
                            size: CGFloat.random(in: 2...6),
                            layer: layer
                        )
                        .offset(
                            x: CGFloat.random(in: -50...geometry.size.width + 50),
                            y: CGFloat.random(in: -50...geometry.size.height + 50)
                        )
                        .animation(
                            .linear(duration: Double.random(in: 8...15))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...5)),
                            value: animationOffset
                        )
                    }
                }
                
                // Twinkling effect overlay
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    starColors[index % starColors.count].opacity(0.6),
                                    starColors[index % starColors.count].opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: CGFloat.random(in: 8...16))
                        .offset(
                            x: CGFloat.random(in: -50...geometry.size.width + 50),
                            y: CGFloat.random(in: -50...geometry.size.height + 50)
                        )
                        .scaleEffect(twinkleAnimation)
                        .opacity(twinkleAnimation)
                        .animation(
                            .easeInOut(duration: Double.random(in: 1...3))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                            value: twinkleAnimation
                        )
                }
            }
        }
        .onAppear {
            withAnimation {
                animationOffset = 1
                twinkleAnimation = 1
            }
        }
    }
}

struct StarView: View {
    let color: Color
    let size: CGFloat
    let layer: Int
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundColor(color)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .animation(
                .easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...1)),
                value: rotation
            )
            .animation(
                .easeInOut(duration: Double.random(in: 1.5...3))
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...0.5)),
                value: scale
            )
            .onAppear {
                rotation = Double.random(in: 0...360)
                scale = CGFloat.random(in: 0.8...1.2)
            }
    }
}

// MARK: - Stunning Enhanced Background with Multiple Layers

struct StunningEnhancedBackground: View {
    @State private var animationOffset: CGFloat = 0
    @State private var twinkleAnimation: CGFloat = 0
    @State private var floatingElements: [Bool] = Array(repeating: false, count: 20)
    @State private var gradientShift: CGFloat = 0
    @State private var particleRotation: Double = 0
    
    private let starColors: [Color] = [
        .black.opacity(0.6),
        Brand.primaryBlue.opacity(0.85),
        Brand.accentBlue.opacity(0.8),
        Brand.lightCoral.opacity(0.7),
        Brand.gamificationAccent.opacity(0.7),
        .cyan.opacity(0.65),
        .mint.opacity(0.65)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vibrant base gradient layer
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.98, blue: 1.0),
                        Color(red: 0.92, green: 0.96, blue: 0.99),
                        Color(red: 0.88, green: 0.94, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                // Very subtle white with slight blue tint overlay
                LinearGradient(
                    colors: [
                        Color.white,
                        Brand.lightBlue.opacity(0.02),
                        Color.white.opacity(0.98)
                    ],
                    startPoint: UnitPoint(x: gradientShift, y: 0),
                    endPoint: UnitPoint(x: gradientShift + 0.5, y: 1)
                )
                .ignoresSafeArea(.all)
                .animation(.easeInOut(duration: 15).repeatForever(autoreverses: false), value: gradientShift)
                
                // Multiple layers of floating stars
                ForEach(0..<4, id: \.self) { layer in
                    ForEach(0..<100, id: \.self) { index in
                        EnhancedStarView(
                            color: starColors[index % starColors.count],
                            size: CGFloat.random(in: 2...8),
                            layer: layer,
                            animationOffset: animationOffset,
                            index: index
                        )
                        .offset(
                            x: CGFloat.random(in: -50...geometry.size.width + 50),
                            y: CGFloat.random(in: -50...geometry.size.height + 50)
                        )
                    }
                }
                
                // Floating geometric shapes
                ForEach(0..<18, id: \.self) { index in
                    FloatingShapeView(
                        color: starColors[index % starColors.count],
                        size: CGFloat.random(in: 20...60),
                        animationOffset: animationOffset,
                        index: index
                    )
                    .offset(
                        x: CGFloat.random(in: -50...geometry.size.width + 50),
                        y: CGFloat.random(in: -120...geometry.size.height + 120)
                    )
                }
                
                // Twinkling effect overlay
                ForEach(0..<32, id: \.self) { index in
                    Circle()
                        .fill(
                        RadialGradient(
                            colors: [
                                starColors[index % starColors.count].opacity(0.9),
                                starColors[index % starColors.count].opacity(0.4),
                                .clear
                            ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: CGFloat.random(in: 6...20))
                        .offset(
                            x: CGFloat.random(in: -50...geometry.size.width + 50),
                            y: CGFloat.random(in: -50...geometry.size.height + 50)
                        )
                        .scaleEffect(twinkleAnimation)
                        .opacity(twinkleAnimation)
                        .animation(
                            .easeInOut(duration: Double.random(in: 1.5...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...3)),
                            value: twinkleAnimation
                        )
                }
                
                // Subtle particle system
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(
                        RadialGradient(
                            colors: [
                                starColors[index % starColors.count].opacity(0.5),
                                starColors[index % starColors.count].opacity(0.15),
                                .clear
                            ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: CGFloat.random(in: 4...12))
                        .offset(
                            x: sin(particleRotation + Double(index) * 0.5) * 200,
                            y: cos(particleRotation + Double(index) * 0.3) * 150
                        )
                        .blur(radius: 1)
                        .animation(
                            .linear(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: false),
                            value: particleRotation
                        )
                }
            }
        }
        .onAppear {
            withAnimation {
                animationOffset = 1
                twinkleAnimation = 1
            }
            
            // Start gradient animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gradientShift = 1.0
            }
            
            // Start particle rotation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    particleRotation = .pi * 2
                }
            }
        }
    }
}

struct EnhancedStarView: View {
    let color: Color
    let size: CGFloat
    let layer: Int
    let animationOffset: CGFloat
    let index: Int
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundColor(color)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(
                .easeInOut(duration: Double.random(in: 3...6))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.1),
                value: rotation
            )
            .animation(
                .easeInOut(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.15),
                value: scale
            )
            .animation(
                .easeInOut(duration: Double.random(in: 2...5))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.2),
                value: opacity
            )
            .onAppear {
                rotation = Double.random(in: 0...360)
                scale = CGFloat.random(in: 0.7...1.3)
                opacity = Double.random(in: 0.3...0.8)
            }
    }
}

struct FloatingShapeView: View {
    let color: Color
    let size: CGFloat
    let animationOffset: CGFloat
    let index: Int
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 0
    
    var body: some View {
        Group {
            if index % 3 == 0 {
                Circle()
                    .fill(color.opacity(0.1))
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            } else if index % 3 == 1 {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Triangle()
                    .fill(color.opacity(0.1))
                    .overlay(
                        Triangle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .opacity(opacity)
        .animation(
            .easeInOut(duration: Double.random(in: 4...8))
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.2),
            value: rotation
        )
        .animation(
            .easeInOut(duration: Double.random(in: 3...6))
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.25),
            value: scale
        )
        .animation(
            .easeInOut(duration: Double.random(in: 2...5))
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.3),
            value: opacity
        )
        .onAppear {
            rotation = Double.random(in: 0...360)
            scale = CGFloat.random(in: 0.5...1.2)
            opacity = Double.random(in: 0.2...0.6)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HomeScrollContentNew(
        store: AppStore(),
        pendingLesson: .constant(nil),
        navigateToLesson: .constant(false),
        animateProgress: .constant(false),
        pulseAnimation: .constant(false),
        animateHeader: .constant(false)
    )
}
