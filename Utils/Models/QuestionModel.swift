//
//  QuestionModel.swift
//  AdirApp
//
//  Created by Ihor Stasiv on 25.11.2021.
//

import Foundation

// MARK: - QuestionModel
struct QuestionModel: Codable {
    let total: Int
    var questions: [Question]
}

// MARK: - Question
struct Question: Codable {
    let quizId: String?
    let id: String
    let studentID: Int?
    let name: String?
    let points: Int?
    let type: String?
    let text: String?
    let answers: String?
    var dictionaryAnswers: [String: String]?
    let intDb: Int

    enum CodingKeys: String, CodingKey {
        case quizId = "quiz_id"
        case id
        case studentID = "student_id"
        case name, points, type, text, answers
        case intDb = "int_db"
    }
}

enum QuestionType: String {
    case fileUpload = "file_upload"
    case essayQuestion = "essay_question"
    case shortAnswer = "short_answer"
    case multipleChoice = "multiple_choice"
    case trueFalse = "true_false"
    case undeclared = ""
}
