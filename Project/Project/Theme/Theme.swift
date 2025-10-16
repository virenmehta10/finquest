//
//  Theme.swift
//  Project
//
//  Colors, gradients, and typography helpers
//

import SwiftUI

enum AppGradient {
    static let hero = LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let card = LinearGradient(colors: [Color.indigo.opacity(0.8), Color.mint.opacity(0.8)], startPoint: .top, endPoint: .bottom)
    static let gold = LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
}

enum AppStyle {
    static func glassBackground(cornerRadius: CGFloat = 20) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

extension Text {
    func heroTitle() -> some View {
        self.font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(AppGradient.gold)
    }

    func sectionTitle() -> some View {
        self.font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary)
    }
}


