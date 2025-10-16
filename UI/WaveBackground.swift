import SwiftUI

struct WaveBackground: View {
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base light blue background
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.92, green: 0.96, blue: 1.0),
                    Color(red: 0.88, green: 0.94, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated wave layers
            ForEach(0..<3, id: \.self) { index in
                WaveShape(offset: waveOffset + CGFloat(index) * 0.3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1 - CGFloat(index) * 0.02),
                                Color.cyan.opacity(0.08 - CGFloat(index) * 0.015),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 200)
                    .offset(y: CGFloat(index) * 50 - 100)
                    .animation(
                        .linear(duration: Double(8 + index * 2))
                        .repeatForever(autoreverses: false),
                        value: waveOffset
                    )
            }
        }
        .onAppear {
            waveOffset = 1
        }
    }
}

struct UltraSoftBackground: View {
    @State private var t: CGFloat = 0
    var body: some View {
        ZStack {
            // ultra soft pastel base
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.99, blue: 1.00),
                    Color(red: 0.97, green: 1.00, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // floating mist blobs
            Circle()
                .fill(LinearGradient(colors: [Color.cyan.opacity(0.10), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(x: -140 + 20 * sin(t), y: -180 + 10 * cos(t/2))

            Circle()
                .fill(LinearGradient(colors: [Color.mint.opacity(0.10), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 520, height: 520)
                .blur(radius: 110)
                .offset(x: 160 * cos(t/3), y: 220)

            Circle()
                .fill(LinearGradient(colors: [Color.purple.opacity(0.06), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 500, height: 500)
                .blur(radius: 120)
                .offset(x: 120, y: -60 * sin(t/4))
        }
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                t = 6.28
            }
        }
    }
}

struct WaveShape: Shape {
    var offset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height * 0.5))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX + offset) * .pi * 2)
            let y = height * 0.5 + sine * height * 0.3
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}


