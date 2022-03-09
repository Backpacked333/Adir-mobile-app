//
//  GoogleUserModel.swift
//  AdirApp
//
//  Created by iMac1 on 04.11.2021.
//

import Foundation

final class GoogleUserModel {
    let refreshToken: String
    let email: String
    
    init(email: String, refreshToken: String) {
        self.refreshToken = refreshToken
        self.email = email
    }
}
