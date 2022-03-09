//
//  UserModel.swift
//  AdirApp
//
//  Created by iMac1 on 22.11.2021.
//

import Foundation

struct UserModel: Codable {
    let id: Int?
    let email: String?
    let full_name: String?
    let last_login: String?
}
