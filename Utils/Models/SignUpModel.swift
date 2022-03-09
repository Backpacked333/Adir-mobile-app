//
//  SignUpModel.swift
//  AdirApp
//
//  Created by Ihor Stasiv on 25.11.2021.
//

import Foundation

struct SignUpModel: Codable {
    let email: String
    let id: Int?
    let password: String?
    let last_login: String?
    let token: Token
}

struct Token: Codable {
    let access_token: String
    let expires: String
}
