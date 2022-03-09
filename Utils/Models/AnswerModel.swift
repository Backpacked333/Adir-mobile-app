//
//  AnswerModel.swift
//  AdirApp
//
//  Created by iMac1 on 07.12.2021.
//

import Foundation

struct AnswerModel: Codable { // TODO W8 for model
    let status: String
}

struct AnswerVoteModel: Codable {
    let quizId: String
    let questionId: String
    let answer: String
    let fileString64: String
}

struct AnswerButtonModel {
    let answer: String
    let answerId: String
    let answerState: Bool
}
