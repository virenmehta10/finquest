//
//  UserProgress.swift
//  Project
//
//  Tracks user points, streaks, and levels
//

import Foundation

struct Level: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let requiredPoints: Int
}

struct UserProgress: Codable, Hashable {
    var totalPoints: Int
    var currentStreak: Int
    var bestStreak: Int
    var currentLevelIndex: Int

    static let defaultLevels: [Level] = [
        Level(id: 0, name: "Analyst I", requiredPoints: 0),
        Level(id: 1, name: "Analyst II", requiredPoints: 200),
        Level(id: 2, name: "Senior Analyst", requiredPoints: 600),
        Level(id: 3, name: "Associate", requiredPoints: 1200),
        Level(id: 4, name: "VP", requiredPoints: 2400),
        Level(id: 5, name: "Director", requiredPoints: 4000),
        Level(id: 6, name: "MD", requiredPoints: 6500)
    ]

    init(totalPoints: Int = 0, currentStreak: Int = 0, bestStreak: Int = 0, currentLevelIndex: Int = 0) {
        self.totalPoints = totalPoints
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.currentLevelIndex = currentLevelIndex
    }
}


