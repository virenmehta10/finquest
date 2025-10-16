//
//  GameEngine.swift
//  Project
//
//  Handles scoring, streaks, levels, and rewards
//

import Foundation
import Combine

final class GameEngine: ObservableObject {
    @Published private(set) var progress: UserProgress

    // Publishers for UI effects
    let streakMilestone = PassthroughSubject<Int, Never>() // emits 5, 10, etc.
    let pointsAwarded = PassthroughSubject<Int, Never>()

    init(progress: UserProgress = UserProgress()) {
        self.progress = progress
    }

    func recordAnswer(isCorrect: Bool) {
        if isCorrect {
            progress.currentStreak += 1
            progress.bestStreak = max(progress.bestStreak, progress.currentStreak)
            let awarded = calculatePoints(forStreak: progress.currentStreak)
            progress.totalPoints += awarded
            pointsAwarded.send(awarded)

            if progress.currentStreak % 5 == 0 {
                streakMilestone.send(progress.currentStreak)
            }

            updateLevelIfNeeded()
        } else {
            progress.currentStreak = 0
        }
    }

    private func calculatePoints(forStreak streak: Int) -> Int {
        // Base 10, exponential growth every 5 streaks
        // 1-4: +10 each, 5: +30, 6-9: +12 each, 10: +60, etc.
        let base = 10
        let multiplier = pow(1.2, Double(streak / 5))
        return Int(Double(base) * multiplier)
    }

    private func updateLevelIfNeeded() {
        let levels = UserProgress.defaultLevels
        var newIndex = progress.currentLevelIndex
        while newIndex + 1 < levels.count && progress.totalPoints >= levels[newIndex + 1].requiredPoints {
            newIndex += 1
        }
        progress.currentLevelIndex = newIndex
    }
}


