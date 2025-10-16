//
//  Module.swift
//  Project
//
//  Represents a learning module (e.g., DCF Fundamentals)
//

import Foundation

struct Lesson: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let questions: [Question]

    init(id: UUID = UUID(), title: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.questions = questions
    }
}

struct Module: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let emoji: String
    let lessons: [Lesson]

    init(id: UUID = UUID(), title: String, subtitle: String, emoji: String, lessons: [Lesson]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.emoji = emoji
        self.lessons = lessons
    }
}


