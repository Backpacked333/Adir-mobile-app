//
//  CommentModel.swift
//  AdirApp
//
//  Created by iMac1 on 27.12.2021.
//

import Foundation

struct PostCommentModel: Codable {
    let status: String
    let comment_id: Int
}

struct GetCommentModel: Codable {
    let quiz_question_id: Int
    let content: String
}
