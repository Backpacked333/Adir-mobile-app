//
//  UserDefaultsService.swift
//  AdirApp
//
//  Created by iMac1 on 04.11.2021.
//

import Foundation

private enum UserDefaultsKeys: String {
    case userIdentifier = "userIdentifier1"
    case loggedUserKey = "LoggedUserModel"
    case token = "Token"
}
 
let userDefaults = UserDefaults.standard

final class UserDefaultsService {
    
    let defaults = UserDefaults.standard
    static func saveIdentifier(identifier: String) {
        userDefaults.set(identifier, forKey: UserDefaultsKeys.userIdentifier.rawValue)
    }
    
    static func getIdentifier() -> String {
        return userDefaults.value(forKey: UserDefaultsKeys.userIdentifier.rawValue) as? String ?? ""
    }
    
    static func saveToken(token: String) {
        userDefaults.set(token, forKey: UserDefaultsKeys.userIdentifier.rawValue)
    }
    
    static func getToken() -> String {
        return userDefaults.value(forKey: UserDefaultsKeys.userIdentifier.rawValue) as? String ?? ""
    }

    
    static func removeAllDefaultsData() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    static func getLoggedUserModel() -> UserModel? {
        guard let data = userDefaults.value(forKey: UserDefaultsKeys.loggedUserKey.rawValue) as? Data else { return nil }
        let model = try? JSONDecoder().decode(UserModel.self, from: data)
        return model
    }
    
    static func saveLoggedUserModel(model: UserModel) {
        let encoded = try! JSONEncoder().encode(model)
        userDefaults.set(encoded, forKey: UserDefaultsKeys.loggedUserKey.rawValue)
    }
    
    static func saveAnswerModel(model: [String: [String: AnswerVoteModel]]) {
        let encoded = try! JSONEncoder().encode(model)
        userDefaults.set(encoded, forKey: StoreConstKeys.answersKey.rawValue)
    }
    
    static func getAnswerModel() -> [String: [String: AnswerVoteModel]]? {
        guard let data = userDefaults.value(forKey: StoreConstKeys.answersKey.rawValue) as? Data else { return nil }
        let model = try? JSONDecoder().decode([String: [String: AnswerVoteModel]].self, from: data)
        return model
    }
    
    static func removeAnswerModel(fromKey: String) {
        guard var answers = UserDefaultsService.getAnswerModel() else { return }
        answers.removeValue(forKey: fromKey)
        saveAnswerModel(model: answers)
    }
}
