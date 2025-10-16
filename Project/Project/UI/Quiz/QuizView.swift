//
//  QuizView.swift
//  Project
//
//  Animated quiz flow with HUD
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var engine: GameEngine
    let lesson: Lesson

    @State private var index: Int = 0
    @State private var showResult: Bool = false
    @State private var lastAward: Int = 0
    @State private var celebrationStreak: Int? = nil
    @Namespace private var animation

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                StreakHUD(streak: engine.progress.currentStreak, points: engine.progress.totalPoints)
                questionCard
                choices
            }
            .padding()

            if let s = celebrationStreak {
                StreakCelebrationView(streak: s)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onReceive(engine.pointsAwarded) { points in
            lastAward = points
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { showResult = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation { showResult = false }
            }
        }
        .onReceive(engine.streakMilestone) { streak in
            celebrationStreak = streak
            let displayTime: TimeInterval = streak % 10 == 0 ? 1.4 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
                withAnimation(.easeInOut) { celebrationStreak = nil }
            }
        }
    }

    private var question: Question { lesson.questions[index] }

    private var questionCard: some View {
        ZStack {
            AppStyle.glassBackground(cornerRadius: 24)
            VStack(alignment: .leading, spacing: 12) {
                Text("Question \(index + 1) of \(lesson.questions.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(question.prompt)
                    .font(.title3.bold())
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
    }

    private var choices: some View {
        VStack(spacing: 12) {
            ForEach(question.choices) { choice in
                Button {
                    engine.recordAnswer(isCorrect: choice.isCorrect)
                    goNext()
                } label: {
                    ChoiceRow(text: choice.text)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func goNext() {
        if index + 1 < lesson.questions.count {
            withAnimation(.spring) { index += 1 }
        }
    }
}

private struct ChoiceRow: View {
    let text: String
    var body: some View {
        ZStack(alignment: .leading) {
            AppStyle.glassBackground(cornerRadius: 16)
            Text(text)
                .font(.body)
                .padding(16)
        }
    }
}

private struct StreakHUD: View {
    let streak: Int
    let points: Int
    var body: some View {
        HStack(spacing: 12) {
            Label("\(streak)", systemImage: "flame.fill")
                .foregroundStyle(.orange)
                .font(.headline)
            Spacer()
            Label("\(points)", systemImage: "bolt.fill")
                .foregroundStyle(.yellow)
                .font(.headline)
        }
        .padding(12)
        .background(AppStyle.glassBackground(cornerRadius: 16))
    }
}

#Preview {
    QuizView(engine: GameEngine(), lesson: Lesson(title: "Preview", questions: QuestionBank.dcfBasics))
}

private struct StreakCelebrationView: View {
    let streak: Int
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 2)
            VStack(spacing: 8) {
                Text("\(streak)🔥 STREAK!")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(AppGradient.gold)
                    .scaleEffect(animate ? 1.0 : 0.6)
                Text("Bonus multiplier active")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .opacity(animate ? 1 : 0)
            }
            .padding(24)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(Circle().stroke(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4).blur(radius: 1))
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
            )
            .scaleEffect(animate ? 1.0 : 0.8)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { animate = true }
            }
        }
    }
}


