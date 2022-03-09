//
//  AuthData.swift
//  AdirApp
//
//  Created by iMac1 on 18.11.2021.
//

import Foundation

class AuthData {
    private let accessTokenKey = "accessToken"

    static let shared = AuthData()

    var isUserLoggedIn: Bool {
        let isUserLoggedIn = accessToken != nil && ((accessToken ?? "") != "")
        return isUserLoggedIn
    }

    private(set) var accessToken: String? {
        get {
            return Store.standard.value(forKey: accessTokenKey) as? String
        }
        set {
            Store.standard.setValue(newValue, forKey: accessTokenKey)
        }
    }

    func setAuthData(withAuthenticationModel authentication: AuthModel) {
        accessToken = authentication.signIn.accessToken
    }
    
    func removeToken() {
        Store.standard.setValue(nil, forKey: accessTokenKey)
    }
}
