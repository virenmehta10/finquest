//
//  ProjectTests.swift
//  ProjectTests
//
//  Created by Viren Mehta on 9/15/25.
//

import Testing
@testable import Project

struct ProjectTests {

    @Test func scoring_increases_with_streaks() async throws {
        let engine = GameEngine()
        let before = engine.progress.totalPoints
        engine.recordAnswer(isCorrect: true)
        engine.recordAnswer(isCorrect: true)
        engine.recordAnswer(isCorrect: true)
        #expect(engine.progress.currentStreak == 3)
        #expect(engine.progress.totalPoints > before)
    }

    @Test func streak_resets_on_wrong_answer() async throws {
        let engine = GameEngine()
        engine.recordAnswer(isCorrect: true)
        engine.recordAnswer(isCorrect: false)
        #expect(engine.progress.currentStreak == 0)
    }

}
