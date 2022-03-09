//
//  SchoolModel.swift
//  AdirApp
//
//  Created by Ihor Stasiv on 11.02.2022.
//

import Foundation

// MARK: - SchoolModel
struct SchoolModel: Codable {
    let id: Int
    let name: String
    let loginFormURL, logoURL: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case loginFormURL = "login_form_url"
        case logoURL = "logo_url"
        case createdAt = "created_at"
    }
}
