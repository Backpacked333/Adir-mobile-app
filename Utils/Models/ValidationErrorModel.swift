//
//  ValidationErrorModel.swift
//  AdirApp
//
//  Created by Ihor Stasiv on 24.11.2021.
//

import Foundation

// MARK: - ErrorStruct
struct ErrorModel: Decodable {
    let detail: String
}

// MARK: - ValidationErrorModel
struct ValidationErrorModel: Codable {
    let detail: [Detail]
}

// MARK: - Detail
struct Detail: Codable {
    let loc: [String]
    let msg, type: String
}
