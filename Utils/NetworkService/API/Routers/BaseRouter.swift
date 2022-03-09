//
//  BaseRouter.swift
//  PregradeIOSApp
//
//  Created by InLogicSoft on 29.04.2021.
//

import Foundation
import Alamofire

let kServerBaseURL = APIConstants.baseURL

class BaseRouter: APIConfiguration {
    init() { }
    
    var encoding: ParameterEncoding? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var header: HTTPHeaders {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var method: HTTPMethod {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var path: String {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var parameters: Parameters? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var keyPath: String? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var baseUrl: String {
        return APIConstants.baseURL
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try APIConstants.baseURL.asURL()
        
        var urlRequest = URLRequest(url: URL(string: url.appendingPathComponent(path).absoluteString.removingPercentEncoding!)!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 300
        urlRequest.headers = header
//        urlRequest.setValue("bfe3dd0f-ec55-40de-b3b1-35918549969e", forHTTPHeaderField: "APIKey")
        
        if let encoding = encoding {
            return try encoding.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }

}
