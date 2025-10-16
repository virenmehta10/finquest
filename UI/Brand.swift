import SwiftUI

// Centralized brand palette and shared surfaces
enum Brand {
    // Core palette - Light Blue Theme (inspired by onboarding screen)
    static let navy = Color(red: 0.04, green: 0.12, blue: 0.27) // #0A1F44
    static let charcoal = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
    static let white = Color.white // #FFFFFF
    static let emerald = Color(red: 0.00, green: 0.78, blue: 0.59) // #00C896
    static let gold = Color(red: 0.96, green: 0.77, blue: 0.09) // #F5C518
    
    // Warm Professional Teal-Blue Theme - Light, warm, and inviting
    static let primaryBlue = Color(red: 0.2, green: 0.7, blue: 0.8) // #33B3CC - Warm teal-blue
    static let lightBlue = Color(red: 0.98, green: 0.99, blue: 1.0) // #FAFCFF - Very light with slight blue tint
    static let softBlue = Color(red: 0.4, green: 0.8, blue: 0.9) // #66CCE6 - Medium teal-blue
    static let warmBlue = Color(red: 0.1, green: 0.6, blue: 0.7) // #1A99B3 - Deeper teal-blue
    static let accentBlue = Color(red: 0.3, green: 0.75, blue: 0.85) // #4DBFD9 - Accent teal-blue
    
    // Single Complementary Color - Warm coral for gamification
    static let gamificationAccent = Color(red: 0.95, green: 0.5, blue: 0.4) // #F28066 - Warm coral
    static let lightCoral = Color(red: 0.98, green: 0.7, blue: 0.6) // #FAB399 - Light coral accent
    
    // Legacy colors - keeping for compatibility but deprecated
    static let lavender = Color(red: 0.6, green: 0.3, blue: 1.0) // #994DFF - Keep for special cases
    static let softPurple = Color(red: 0.7, green: 0.4, blue: 1.0) // #B366FF - Keep for special cases
    static let softMint = Color(red: 0.0, green: 0.9, blue: 0.7) // #00E6B3 - Keep for special cases
    
    // Deprecated clashing colors - replaced with warm palette
    static let softGreen = gamificationAccent // Redirect to gamification accent
    static let warmCoral = gamificationAccent // Redirect to gamification accent
    static let gentlePurple = warmBlue // Redirect to warm blue
    static let softYellow = gamificationAccent // Redirect to gamification accent
    static let lightPink = gamificationAccent // Redirect to gamification accent
    static let softOrange = gamificationAccent // Redirect to gamification accent
    static let paleGreen = gamificationAccent // Redirect to gamification accent
    static let lightGray = Color(red: 0.96, green: 0.97, blue: 0.98) // #F5F7FA - Soft gray backgrounds
    static let dullLightBlue = lightBlue // Redirect to light blue
    
    // Legacy aliases for compatibility
    static let teal = warmBlue // Redirect to warm blue
    static let mint = softBlue // Redirect to soft blue
    static let deepTeal = warmBlue // Redirect to warm blue
    
    // Legacy aliases for compatibility
    static let coolBlue = primaryBlue

    // Warm Professional Gradients - Light and inviting
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, warmBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [softBlue, accentBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [primaryBlue, warmBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let mintGradient = LinearGradient(
        colors: [softBlue, lightBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Gamification Gradients - All using the warm coral accent
    static let gamificationGradient = LinearGradient(
        colors: [gamificationAccent, lightCoral],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let softGreenGradient = gamificationGradient // Redirect to gamification gradient
    static let warmCoralGradient = gamificationGradient // Redirect to gamification gradient
    static let gentlePurpleGradient = LinearGradient(
        colors: [warmBlue, primaryBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let softYellowGradient = gamificationGradient // Redirect to gamification gradient
    
    // Subtle Professional Background gradients - White with very slight blue tint
    static let backgroundGradient = LinearGradient(
        colors: [Color.white, lightBlue.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Subtle onboarding-style background gradient
    static let onboardingBackgroundGradient = LinearGradient(
        colors: [Color.white, lightBlue.opacity(0.05), Color.white.opacity(0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.9), lightBlue.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Legacy gradients (keeping for compatibility)
    static let gradient = LinearGradient(
        colors: [
            navy.opacity(0.98),
            Color.indigo.opacity(0.88)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let emeraldGradient = LinearGradient(
        colors: [emerald, Color.green.opacity(0.7)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let goldGradient = LinearGradient(
        colors: [gold.opacity(0.95), Color.orange.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Surfaces & text (Light theme)
    static let surface = Color.white
    static let card = Color.white
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1) // Dark text for light theme
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4) // Medium gray text
    static let border = Color(red: 0.9, green: 0.9, blue: 0.95) // Light border

	// Vibrant Glassmorphism Surfaces
	static let glassmorphismBackground = LinearGradient(
		colors: [
			Color.white.opacity(0.9),
			lightBlue.opacity(0.4)
		],
		startPoint: .topLeading,
		endPoint: .bottomTrailing
	)
	
	static let glassmorphismBorder = Color(red: 0.6, green: 0.8, blue: 1.0) // More vibrant border
	
	// Vibrant pastel gradient for CTAs
	static let pastelGradient = LinearGradient(
		colors: [
			primaryBlue.opacity(0.8), // Vibrant blue tint
			teal.opacity(0.6)   // Vibrant teal tint
		],
		startPoint: .topLeading,
		endPoint: .bottomTrailing
	)
	
    // Warm accent colors
    static let accentMint = softBlue
    static let accentPurple = warmBlue
    static let accentOrange = gamificationAccent // Redirect to gamification accent
    static let accentGreen = gamificationAccent // Redirect to gamification accent
	
	// Light theme shadow colors
    static let shadowLight = Color.black.opacity(0.08)
    static let shadowMedium = Color.black.opacity(0.12)
    static let shadowHeavy = Color.black.opacity(0.20)
}

// MARK: - Typography System

extension Brand {
    // Font styles matching onboarding screen aesthetic
    static let titleFont = Font.system(size: 32, weight: .bold, design: .rounded)
    static let largeTitleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 22, weight: .bold, design: .rounded)
    static let subheadlineFont = Font.system(size: 18, weight: .medium, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .medium, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let smallFont = Font.system(size: 12, weight: .medium, design: .rounded)
    
    // Button fonts
    static let buttonFont = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let largeButtonFont = Font.system(size: 18, weight: .bold, design: .rounded)
    
    // Special fonts
    static let taglineFont = Font.system(size: 16, weight: .medium, design: .rounded)
    static let descriptionFont = Font.system(size: 14, weight: .regular, design: .rounded)
}


// MARK: - Design System

struct FrostedCard: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(Brand.card.opacity(0.9))
            .background(
                LinearGradient(colors: [Brand.card.opacity(0.9), Brand.navy.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Brand.border, lineWidth: 1)
            )
            .shadow(color: Brand.shadowMedium, radius: 18, x: 0, y: 10)
    }
}

extension View {
    func frostedCard(cornerRadius: CGFloat = 18) -> some View {
        modifier(FrostedCard(cornerRadius: cornerRadius))
    }
}

struct PrimaryCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.largeButtonFont)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Brand.accentGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Brand.primaryBlue.opacity(configuration.isPressed ? 0.25 : 0.35), radius: configuration.isPressed ? 8 : 16, x: 0, y: configuration.isPressed ? 4 : 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SecondaryCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.buttonFont)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Brand.card)
            .foregroundColor(Brand.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Brand.border, lineWidth: 1))
            .shadow(color: Brand.shadowLight, radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Soft System-Wide Button Styles

struct SoftDefaultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.bodyFont)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Brand.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Brand.border, lineWidth: 1)
            )
            .foregroundColor(Brand.textPrimary)
            .shadow(color: Brand.shadowLight, radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct SoftPillAccentStyle: ButtonStyle {
    var accent: Color = Brand.teal
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.buttonFont)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(accent.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(accent.opacity(0.25), lineWidth: 1)
            )
            .foregroundColor(accent)
            .shadow(color: accent.opacity(configuration.isPressed ? 0.1 : 0.18), radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct CompactPrimaryCTAStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.buttonFont)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .background(Brand.accentGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
            )
            .shadow(color: Brand.primaryBlue.opacity(configuration.isPressed ? 0.25 : 0.4), radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct ModernGetStartedStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.buttonFont)
            .padding(.vertical, 16)
            .padding(.horizontal, 28)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.73, blue: 0.66), // soft coral/red
                        Color(red: 0.78, green: 0.89, blue: 0.98)   // soft sky blue
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color(red: 0.97, green: 0.73, blue: 0.66).opacity(configuration.isPressed ? 0.2 : 0.3),
                radius: configuration.isPressed ? 6 : 12,
                x: 0,
                y: configuration.isPressed ? 3 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Light Blue Button Styles

struct FuturisticCalmPrimaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.largeButtonFont)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                ZStack {
                    Brand.accentGradient
                    Brand.glassmorphismBackground
                }
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Brand.glassmorphismBorder, lineWidth: 1)
            )
            .shadow(color: Brand.primaryBlue.opacity(configuration.isPressed ? 0.3 : 0.5), radius: configuration.isPressed ? 8 : 16, x: 0, y: configuration.isPressed ? 4 : 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct FuturisticCalmSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Brand.subheadlineFont)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    Brand.glassmorphismBackground
                    Brand.secondaryGradient.opacity(0.3)
                }
            )
            .foregroundColor(Brand.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Brand.glassmorphismBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(configuration.isPressed ? 0.1 : 0.2), radius: configuration.isPressed ? 4 : 8, x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct AnimatedBackground: View {
    @State private var animate: Bool = false
    var body: some View {
        ZStack {
            Brand.backgroundGradient
                .ignoresSafeArea()
            Circle()
                .fill(LinearGradient(colors: [Brand.teal.opacity(0.15), Brand.mint.opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 90)
                .frame(width: 420, height: 420)
                .offset(x: animate ? -120 : 60, y: animate ? -160 : -40)
            Circle()
                .fill(LinearGradient(colors: [Brand.primaryBlue.opacity(0.12), Brand.lavender.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 100)
                .frame(width: 520, height: 520)
                .offset(x: animate ? 120 : -40, y: animate ? 240 : 80)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Enhanced Animated Gradient Background with Sophisticated Color Splashes

struct AnimatedGradientBackgroundWithSplashes: View {
    @State private var animate: Bool = false
    @State private var particleOffset: CGFloat = 0
    @State private var gradientOffset: CGFloat = 0
    @State private var secondaryGradientOffset: CGFloat = 0
    @State private var splashAnimations: [Bool] = Array(repeating: false, count: 12)
    
    var body: some View {
        ZStack {
            // Base gradient - sophisticated multi-layer foundation
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.98, blue: 1.0), // Soft white-blue
                    Color(red: 0.94, green: 0.96, blue: 0.99), // Gentle transition
                    Color(red: 0.92, green: 0.94, blue: 0.98), // Subtle depth
                    Color(red: 0.90, green: 0.92, blue: 0.96)  // Warm undertone
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Primary moving gradient - sophisticated wave motion
            LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.92, blue: 0.96).opacity(0.4),
                    Color(red: 0.85, green: 0.89, blue: 0.94).opacity(0.3),
                    Color(red: 0.82, green: 0.86, blue: 0.92).opacity(0.2),
                    Color(red: 0.80, green: 0.84, blue: 0.90).opacity(0.1)
                ],
                startPoint: UnitPoint(x: gradientOffset, y: 0),
                endPoint: UnitPoint(x: gradientOffset + 0.6, y: 1)
            )
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 12).repeatForever(autoreverses: false), value: gradientOffset)
            
            // Secondary gradient - counter-rotating for depth
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.88, blue: 0.92).opacity(0.2),
                    Color(red: 0.88, green: 0.86, blue: 0.90).opacity(0.15),
                    Color(red: 0.86, green: 0.84, blue: 0.88).opacity(0.1)
                ],
                startPoint: UnitPoint(x: 1 - secondaryGradientOffset, y: 0),
                endPoint: UnitPoint(x: 1 - secondaryGradientOffset - 0.4, y: 1)
            )
            .ignoresSafeArea(.all)
            .animation(.easeInOut(duration: 16).repeatForever(autoreverses: false), value: secondaryGradientOffset)
            
            // Sophisticated color splashes - organic floating shapes
            ForEach(0..<12, id: \.self) { index in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                vibrantColors[index % vibrantColors.count].opacity(0.15),
                                vibrantColors[index % vibrantColors.count].opacity(0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(
                        width: CGFloat(Double.random(in: 200...400)),
                        height: CGFloat(Double.random(in: 150...300))
                    )
                    .offset(
                        x: sin(particleOffset + Double(index) * 0.8) * 150,
                        y: cos(particleOffset + Double(index) * 0.6) * 100
                    )
                    .blur(radius: 3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 12...20))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...4)),
                        value: particleOffset
                    )
            }
            
            // Additional subtle floating elements
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                vibrantColors[index % vibrantColors.count].opacity(0.08),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: CGFloat(Double.random(in: 80...160)))
                    .offset(
                        x: cos(particleOffset * 0.7 + Double(index) * 1.2) * 200,
                        y: sin(particleOffset * 0.5 + Double(index) * 0.9) * 120
                    )
                    .blur(radius: 2)
                    .animation(
                        .easeInOut(duration: Double.random(in: 15...25))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...6)),
                        value: particleOffset
                    )
            }
        }
        .onAppear {
            animate = true
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                particleOffset = .pi * 2
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                gradientOffset = 1.0
            }
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                secondaryGradientOffset = 1.0
            }
        }
    }
    
    // Warm professional color palette for background animations
    private let vibrantColors: [Color] = [
        Brand.primaryBlue, // Warm light blue
        Brand.softBlue, // Medium warm blue
        Brand.warmBlue, // Deeper warm blue
        Brand.accentBlue, // Accent warm blue
        Brand.gamificationAccent, // Warm coral accent
        Brand.lightCoral, // Light coral accent
        Brand.primaryBlue.opacity(0.6), // Warm blue variant
        Brand.softBlue.opacity(0.6), // Medium blue variant
        Brand.warmBlue.opacity(0.6), // Deep blue variant
        Brand.accentBlue.opacity(0.6), // Accent blue variant
        Brand.gamificationAccent.opacity(0.6), // Coral variant
        Brand.lightCoral.opacity(0.6) // Light coral variant
    ]
}

// MARK: - Parameterized Animated Gradient Background (for compatibility)

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(colors: [Color] = [Color.blue.opacity(0.8), Color.purple.opacity(0.6), Color.mint.opacity(0.4)], 
         startPoint: UnitPoint = .topLeading, 
         endPoint: UnitPoint = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? endPoint : startPoint,
            endPoint: animateGradient ? startPoint : endPoint
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Legacy Background (keeping for compatibility)

struct FuturisticCalmBackground: View {
    @State private var animate: Bool = false
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient - light blue theme
            Brand.backgroundGradient
                .ignoresSafeArea()
            
            // Floating particles
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Brand.primaryBlue.opacity(0.08),
                                Brand.teal.opacity(0.04),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: CGFloat.random(in: 20...80))
                    .offset(
                        x: sin(particleOffset + Double(index) * 0.5) * 100,
                        y: cos(particleOffset + Double(index) * 0.3) * 60
                    )
                    .blur(radius: 2)
                    .animation(
                        .easeInOut(duration: Double.random(in: 8...15))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...3)),
                        value: particleOffset
                    )
            }
            
            // Gradient shift animation
            Brand.secondaryGradient
                .opacity(animate ? 0.2 : 0.05)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                particleOffset = .pi * 2
            }
        }
    }
}


