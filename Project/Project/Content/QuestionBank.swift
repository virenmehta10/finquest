//
//  QuestionBank.swift
//  Project
//
//  Seed content for modules and lessons
//

import Foundation

enum QuestionBank {
    static let dcfBasics: [Question] = [
        Question(
            prompt: "What does DCF stand for?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Discounted Cash Flow", isCorrect: true),
                AnswerChoice(text: "Deferred Cash Fund", isCorrect: false),
                AnswerChoice(text: "Distributed Capital Financing", isCorrect: false),
                AnswerChoice(text: "Debt Coverage Formula", isCorrect: false)
            ],
            explanation: "DCF values a business by projecting future free cash flows and discounting them back to present value."
        ),
        Question(
            prompt: "Which rate is commonly used as the discount rate in a DCF?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "WACC", isCorrect: true),
                AnswerChoice(text: "Net Margin", isCorrect: false),
                AnswerChoice(text: "EBITDA", isCorrect: false),
                AnswerChoice(text: "Beta", isCorrect: false)
            ],
            explanation: "Weighted Average Cost of Capital reflects the opportunity cost of capital to all providers."
        ),
    ]

    static let threeStatements: [Question] = [
        Question(
            prompt: "Increasing depreciation has what immediate effect on cash flow?",
            kind: .singleChoice,
            choices: [
                AnswerChoice(text: "Increases cash flow", isCorrect: true),
                AnswerChoice(text: "Decreases cash flow", isCorrect: false),
                AnswerChoice(text: "No effect", isCorrect: false)
            ],
            explanation: "Non-cash expense reduces taxable income, lowering taxes paid; CFO increases."
        )
    ]

    static let modules: [Module] = [
        Module(
            title: "DCF Fundamentals",
            subtitle: "Master valuation basics",
            emoji: "💸",
            lessons: [
                Lesson(title: "Basics", questions: dcfBasics)
            ]
        ),
        Module(
            title: "3 Statements",
            subtitle: "IS, BS, and CF linkage",
            emoji: "📊",
            lessons: [
                Lesson(title: "Linkages", questions: threeStatements)
            ]
        )
    ]
}


