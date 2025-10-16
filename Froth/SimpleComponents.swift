import SwiftUI

struct GlassmorphismCard: View {
    let content: AnyView
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init<Content: View>(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = AnyView(content())
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Brand.glassmorphismBorder, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 5)
            )
    }
}

// MARK: - Enhanced Futuristic Calm Components

struct FloatingParticles: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Floating circles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Brand.coolBlue.opacity(0.03),
                                Brand.lavender.opacity(0.02),
                                Brand.mint.opacity(0.01),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(Double.random(in: 20...60)))
                    .blur(radius: 1)
                    .offset(
                        x: CGFloat(Double.random(in: -150...150)),
                        y: animate ? CGFloat(Double.random(in: -200...200)) : CGFloat(Double.random(in: -300...300))
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...8))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
            
            // Sparkles
            ForEach(0..<15, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.caption)
                    .foregroundColor(Brand.mint.opacity(0.3))
                    .offset(
                        x: CGFloat(Double.random(in: -200...200)),
                        y: animate ? CGFloat(Double.random(in: -300...300)) : CGFloat(Double.random(in: -400...400))
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...10))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...3)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct FadeInEffect: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
    
    func fadeInEffect() -> some View {
        modifier(FadeInEffect())
    }
}

// MARK: - Confetti Effect

struct ConfettiView: View {
    @State private var time: CGFloat = 0
    let colors: [Color] = [.pink, .blue, .purple, .mint, .orange, .yellow]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let _ = time = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
            Canvas { context, size in
                for i in 0..<80 {
                    var transform = CGAffineTransform.identity
                    let x = CGFloat(i) / 80.0 * size.width
                    let y = (time.truncatingRemainder(dividingBy: 5) / 5 + CGFloat(i) * 0.01).truncatingRemainder(dividingBy: 1) * size.height
                    transform = transform.translatedBy(x: x, y: y)
                    transform = transform.rotated(by: CGFloat(i) * 0.2 + time)
                    context.concatenate(transform)
                    let rect = CGRect(x: -3, y: -6, width: 6, height: 12)
                    context.fill(Path(ellipseIn: rect), with: .color(colors[i % colors.count].opacity(0.9)))
                    context.concatenate(transform.inverted())
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Floating Effect

struct FloatingEffect: ViewModifier {
    let phase: CGFloat
    func body(content: Content) -> some View {
        content
            .offset(y: sin(phase) * 4)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: phase)
    }
}

