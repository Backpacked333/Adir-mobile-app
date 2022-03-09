//
//  AuthModel.swift
//  AdirApp
//
//  Created by iMac1 on 18.11.2021.
//

import Foundation

class AuthModel: Codable {
    var signIn: SignInModel

    init(signIn: SignInModel) {
        self.signIn = signIn
    }
}

class SignInModel: Codable {
    var accessToken: String

    init(aToken: String) {
        accessToken = aToken
    }
}
