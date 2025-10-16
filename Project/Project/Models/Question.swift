//
//  Question.swift
//  Project
//
//  Core quiz question model
//

import Foundation

enum QuestionKind: String, Codable, CaseIterable, Identifiable {
    case singleChoice
    case trueFalse
    case numericInput

    var id: String { rawValue }
}

struct AnswerChoice: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let isCorrect: Bool

    init(id: UUID = UUID(), text: String, isCorrect: Bool) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
    }
}

struct Question: Codable, Identifiable, Hashable {
    let id: UUID
    let prompt: String
    let kind: QuestionKind
    let choices: [AnswerChoice]
    let explanation: String

    init(id: UUID = UUID(), prompt: String, kind: QuestionKind, choices: [AnswerChoice], explanation: String) {
        self.id = id
        self.prompt = prompt
        self.kind = kind
        self.choices = choices
        self.explanation = explanation
    }
}


