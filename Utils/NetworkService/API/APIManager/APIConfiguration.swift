//
//  APIConfiguration.swift
//  PregradeIOSApp
//
//  Created by InLogicSoft on 29.04.2021.
//

import Foundation
import Alamofire

protocol APIConfiguration: URLRequestConvertible {
    
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var encoding: Alamofire.ParameterEncoding? { get }
}
