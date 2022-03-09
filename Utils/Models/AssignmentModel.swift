//
//  AssignmentModel.swift
//  AdirApp
//
//  Created by iMac1 on 22.11.2021.
//

import Foundation

// MARK: - AssignmentModel
struct AssignmentModel: Codable {
    let intDB, studentID: Int?
    let id, description: String?
    let dueAt: String?
    var date: Date?
    let pointsPossible, gradingType, allowedAttempts: String?
//    let courseID: Int?
    let name, submissionTypes, hasSubmittedSubmissions: String?
    let dueDateRequired: String?
    let workflowState: String?
    let htmlURL: String?
    let quizID: String?
    let locked: String?

    enum CodingKeys: String, CodingKey {
        case intDB = "int_db"
        case studentID = "student_id"
        case id
        case description = "description"
        case dueAt = "due_at"
        case date
        case pointsPossible = "points_possible"
        case gradingType = "grading_type"
        case allowedAttempts = "allowed_attempts"
//        case courseID = "course_id"
        case name
        case submissionTypes = "submission_types"
        case hasSubmittedSubmissions = "has_submitted_submissions"
        case dueDateRequired = "due_date_required"
        case workflowState = "workflow_state"
        case htmlURL = "html_url"
        case quizID = "quiz_id"
        case locked
    }
}
