//
//  APIManager.swift
//  AdirApp
//
//  Created by iMac1 on 15.11.2021.
//

import UIKit
import Alamofire

let paginationLimit = 10

struct EmptyResponseModel: Codable {}

typealias Response<T> = (Result<T, APIError>) -> Void
typealias EmptyResponse = (Result<EmptyResponseModel, APIError>) -> Void

final class APIManager {
    
    // MARK: - Const
    
    enum Result<T> {
        case success(T)
        case failure((String, String))
    }
    
    // MARK: - POST Requests
    
    static func registration(
        userName: String,
        email: String,
        password: String,
        canvasLogin: String,
        canvasPassword: String,
        completion: @escaping Response<SignUpModel>
    ) {
        let params = ["full_name":userName,
                      "email":email,
                      "password":password,
                      "external_login":canvasLogin,
                      "external_password":canvasPassword,
        ]
        
        let router = RequestsRouter(anEndpoint: .signUP(params))
        performRequest(router: router, completion: completion)
    }
    
    static func login(
        email: String,
        password: String,
        completion: @escaping Response<Token>
    ) {
        let params = codeParametersToString(userName: email, password: password)

        let router = RequestsRouter(anEndpoint: .login(params))
        performRequest(router: router, completion: completion)
    }
    
    static func quizAnswer(
        params: [String: Any],
        completion: @escaping Response<AnswerModel>
    ) {
        let router = RequestsRouter(anEndpoint: .quizAnswer(params))
        performRequest(router: router, completion: completion)
    }
    
    static func addComment(
        questionIntDb: String,
        content: String,
        completion: @escaping Response<PostCommentModel>
    ) {
        let params: [String: Any] = ["quiz_question_id": questionIntDb,
                      "content": content
        ]
        let router = RequestsRouter(anEndpoint: .addComment(params))
        performRequest(router: router, completion: completion)
    }
    
    static func addSchool(
        params: [String: Any],
        completion: @escaping Response<SchoolModel>) {
        let router = RequestsRouter(anEndpoint: .postSchool(params))
        performRequest(router: router, completion: completion)
    }
    
    static func schoolsLogin(
        params: [String: Any],
        completion: @escaping Response<EmptyResponseModel>) {
            let router = RequestsRouter(anEndpoint: .schoolsLogin(params))
            performEmptyResponseRequest(router: router, completion: completion)
        }
    
//    static func assignmentAnswer(
//        assignmentId: String,
//        imageAnswer: UIImage,
//        completion: @escaping Response<AnswerModel>
//    ) {
//        let params: [String : Any] = [
//                      "assignment_id": assignmentId,
//                      "file": imgData
//        ]
//
//        let router = RequestsRouter(anEndpoint: .assignmentAnswer(params))
//        performRequest(router: router, completion: completion)
//    }
    
    // MARK: - PATCH Requests
    
    static func patchSchool(
        params: [String: Any],
        completion: @escaping Response<EmptyResponseModel>) {
            let router = RequestsRouter(anEndpoint: .schoolPatch(params))
            performEmptyResponseRequest(router: router, completion: completion)
    }
    
    // MARK: - GET Requests
    
    static func getUser(
        completion: @escaping Response<UserModel>
    ) {
        let router = RequestsRouter(anEndpoint: .getUser)
        performRequest(router: router, completion: completion)
    }
    
    static func getAssignments(
        completion: @escaping Response<[AssignmentModel]>
    ) {
        let router = RequestsRouter(anEndpoint: .assignments)
        performRequest(router: router, completion: completion)
    }
    
    static func getQuizzes(
        completion: @escaping Response<[AssignmentModel]>
    ) {
        let router = RequestsRouter(anEndpoint: .quizzes)
        performRequest(router: router, completion: completion)
    }
    
    static func getAssignment(
        id: Int,
        completion: @escaping Response<AssignmentModel>
    ) {
        let router = RequestsRouter(anEndpoint: .assignment(String(id)))
        performRequest(router: router, completion: completion)
    }
    
    static func getQuizze(
        id: Int,
        completion: @escaping Response<AssignmentModel>
    ) {
        let router = RequestsRouter(anEndpoint: .quizze(String(id)))
        performRequest(router: router, completion: completion)
    }
    
    static func getQuestion(
        id: String,
        skip: Int = 0,
        limit: Int = paginationLimit,
        completion: @escaping Response<QuestionModel>
    ) {
        let params = [
            "skip":skip,
            "limit":limit
        ]
        
        let router = RequestsRouter(anEndpoint: .questions(id, params))
        performRequest(router: router, completion: completion)
    }
    
    static func getComments(
        questionIntDb: String,
        completion: @escaping Response<[GetCommentModel]>
    ) {
        let router = RequestsRouter(anEndpoint: .getComments("\(questionIntDb)"))
        performRequest(router: router, completion: completion)
    }
    
    static func getSchools(
        completion: @escaping Response<[SchoolModel]>) {
        let router = RequestsRouter(anEndpoint: .getSchools)
        performRequest(router: router, completion: completion)
    }
    
    // MARK: - Perform methods
    private static func performRequest<T: Codable>(router: BaseRouter, decoder: JSONDecoder = JSONDecoder(), completion: @escaping Response<T>) {
        print("API -->: \(router.path), params: \(String(describing: router.parameters ?? nil)) ")
        print("encoding: \(String(describing: router.encoding))")

        AF.request(router).validate(statusCode: 200 ..< 300).responseDecodable(decoder: decoder) { (response: AFDataResponse<T>) in
            print("API <---: \(router.path)")
            let statusCode = response.response?.statusCode ?? -1
            print("Status Code = \(statusCode)")
            if statusCode == 401 {
                DispatchQueue.main.async {
                    AF.session.getAllTasks { (tasks) in
                        tasks.forEach({$0.cancel()})
                    }
                    completion(.failure(self.parseApiError(data: response.data)))
                }
                return
            }
            
            switch response.result {
            case let .success(object):
                print(object)
                completion(.success(object))
            case let .failure(err):
                if response.data == nil {
                    completion(.failure(.failedAPICall(err.localizedDescription)))
                } else {
                    completion(.failure(self.parseApiError(data: response.data)))
                }
            }
        }
    }
    
    private static func performEmptyResponseRequest(router: BaseRouter, completion: @escaping Response<EmptyResponseModel>) {
        print("API -->: \(router.path), params: \(String(describing: router.parameters ?? nil)) ")
        print("encoding: \(String(describing: router.encoding))")

        AF.request(router).validate(statusCode: 200 ..< 300).response() { response in
            print("API <---: \(router.path)")
            let statusCode = response.response?.statusCode ?? -1
            print("Status Code = \(statusCode)")
            if statusCode == 401 {
                DispatchQueue.main.async {
                    AF.session.getAllTasks { (tasks) in
                        tasks.forEach({$0.cancel()})
                    }
                    completion(.failure(self.parseApiError(data: response.data)))
                }
                return
            }
            
            switch response.result {
            case let .success(object):
                completion(.success(EmptyResponseModel()))
            case let .failure(err):
                if response.data == nil {
                    completion(.failure(.failedAPICall(err.localizedDescription)))
                } else {
                    completion(.failure(self.parseApiError(data: response.data)))
                }
            }
        }
    }
    
    // MARK: - Error handling
    private static func parseApiError(data: Data?) -> APIError {
        let requestError = "request error"
        guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .failedAPICall(requestError)
        }
        
        guard let messageBlock = json["error"] as? [String: Any] else {
            return .failedAPICall(requestError)
        }
        
        let mesages = messageBlock["message"] as? String
        
        return .failedAPICall(mesages ?? requestError)
    }
}

// MARK: - Replacing simbols
extension APIManager {
    static func codeParametersToString(userName: String, password: String) -> String {
        var string = ""
        let userName = userName.replacingOccurrences(of: "@", with: "%40", options: .literal, range: nil)
        string = "username=\(userName)&password=\(password)"

        return string
    }
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        
        return request
    }
}

// MARK: - String to JSON
extension APIManager {
    static func getJSON(from: String?) -> [String: String]? {
        guard let string = from, let data = string.data(using: .utf8) else { return nil }
        do {
            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,String> {
                print(jsonDictionary)
                return jsonDictionary
            } else {
                print("bad json")
                return nil
            }
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
