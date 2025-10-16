//
//  HomeView.swift
//  Project
//
//  Stunning home with hero and module grid
//

import SwiftUI

struct HomeView: View {
    @StateObject private var engine = GameEngine()
    private let modules = QuestionBank.modules

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    hero
                    moduleGrid
                }
                .padding()
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            AppGradient.hero
                .mask(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                )
                .frame(height: 180)
                .overlay(AppStyle.glassBackground(cornerRadius: 28))

            VStack(alignment: .leading, spacing: 8) {
                Text("Froth Finance")
                    .heroTitle()
                Text("Level \(UserProgress.defaultLevels[engine.progress.currentLevelIndex].name) • \(engine.progress.totalPoints) pts")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
    }

    private var moduleGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(modules) { module in
                NavigationLink(value: module.id) {
                    ModuleCard(module: module)
                }
                .navigationDestination(for: UUID.self) { id in
                    if let selected = modules.first(where: { $0.id == id }), let first = selected.lessons.first {
                        QuizView(engine: engine, lesson: first)
                    }
                }
            }
        }
    }
}

private struct ModuleCard: View {
    let module: Module
    var body: some View {
        ZStack {
            AppStyle.glassBackground()
            VStack(spacing: 8) {
                Text(module.emoji).font(.system(size: 36))
                Text(module.title).sectionTitle()
                Text(module.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(height: 140)
    }
}

#Preview {
    HomeView()
}


