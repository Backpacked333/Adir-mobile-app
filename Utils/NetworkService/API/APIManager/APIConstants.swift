//
//  APIConstants.swift
//  AdirApp
//
//  Created by iMac1 on 06.12.2021.
//

import Foundation
import Alamofire

struct APIConstants {
    static let baseURL = "http://3.20.44.23/"
}

enum APIError: Error {
    case failedAPICall(String)

    func errMessage() -> String {
        switch self {
        case let .failedAPICall(message):
            return message
        }
    }
}
