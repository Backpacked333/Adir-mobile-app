//
//  ValidationHelper.swift
//  Umity
//
//  Created by Vladyslav Kozlovskyi on 16.07.2021.
//

import UIKit

enum ValidationResult: Equatable {
    case valid
    case invalid(String?)
}

class ValidationHelper {
    
    static let emailPattern = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
    static let decimalPattern = "^\\d*$"
    static let passwordPattern = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$"
    
    static func validatePassword(_ password: String?) -> ValidationResult {
       // if NSPredicate(format: "SELF MATCHES %@", ValidationHelper.passwordPattern).evaluate(with: password) {
        if password?.count ?? 0 > 6 {
            return .valid
        }
        return .invalid("not valid")
    }
    
    static func validateName(_ eventName: String?) -> ValidationResult {
        if eventName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count ?? 0 >= 3 {
            return .valid
        }
        return .invalid(nil)
    }
    
    static func validateEventHighlight(_ highlight: String?) -> ValidationResult {
        if highlight?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count ?? 0 > 0 {
            return .valid
        }
        return .invalid(nil)
    }
    static func validateEmail(_ email: String?) -> ValidationResult {
        if NSPredicate(format: "SELF MATCHES %@", ValidationHelper.emailPattern).evaluate(with: email) {
            return .valid
        }
        return .invalid("not valid")
    }
    
    static func validateNonEmptyString(_ string: String?) -> ValidationResult {
        guard let string = string else { return .invalid(nil) }
        if string.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            return .valid
        }
        return .invalid(nil)
    }
    
    static func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}

extension ValidationResult {
    static func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid):
            return true
        case (.invalid, .invalid):
            return true
        default:
            return false
        }
    }
}


