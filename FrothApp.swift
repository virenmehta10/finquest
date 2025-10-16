//
//  FrothApp.swift
//  Froth
//
//  Created by Viren Mehta on 9/15/25.
//

import SwiftUI

@main
struct FrothApp: App {
    @StateObject private var store = AppStore.load()

    var body: some Scene {
        WindowGroup {
            ZStack {
                AnimatedGradientBackgroundWithSplashes()
                ContentView()
            }
            .environmentObject(store)
            .preferredColorScheme(store.selectedTheme.colorScheme)
            .buttonStyle(SoftDefaultButtonStyle())
        }
    }
}
