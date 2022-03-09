//
//  RequestsRouter.swift
//  AdirApp
//
//  Created by iMac1 on 06.12.2021.
//

import Alamofire

enum MediaEndpoint {
    case signUP(Parameters)
    case login(ParameterEncoding)
    case getUser
    case assignments
    case quizzes
    case assignment(String)
    case quizze(String)
    case questions(String, Parameters)
    case quizAnswer(Parameters)
    case addComment(Parameters)
    case getComments(String)
    case getSchools
    case postSchool(Parameters)
    case schoolsLogin(Parameters)
    case schoolPatch(Parameters)
}

final class RequestsRouter: BaseRouter {
    fileprivate var endpoint: MediaEndpoint

    init(anEndpoint: MediaEndpoint) {
        endpoint = anEndpoint
    }

    override var method: HTTPMethod {
        switch endpoint {
        case .signUP, .login, .quizAnswer, .addComment, .postSchool, .schoolsLogin:
            return .post
        case .getUser, .assignments, .quizzes, .assignment, .quizze, .questions, .getComments, .getSchools:
            return .get
        case .schoolPatch:
            return .patch
        }
    }
    
    override var header: HTTPHeaders {
        switch endpoint {
        case .assignments, .quizzes, .questions, .getUser, .quizAnswer, .addComment, .getComments:
            let headers: HTTPHeaders = [.authorization(bearerToken: UserDefaultsService.getToken())]
            return headers
        default:
            return HTTPHeaders()
        }
    }

    override var path: String {
        switch endpoint {
        case .signUP:
            return "users/sign-up"
        case .login:
            return "users/log-in"
        case .getUser:
            return "users/me"
        case .assignments:
            return "assignments/"
        case .quizzes:
            return "assignments/quizzes"
        case let .assignment(assignmentId):
            return "assignments/\(assignmentId)"
        case let .quizze(quizzeId):
            return "assignments/quizzes/\(quizzeId)"
        case let .questions(quizzeId, _):
            return "assignments/quizzes/\(quizzeId)/questions"
        case .quizAnswer:
            return "assignments/quizzes/answer"
        case .addComment:
            return "comments/add"
        case let .getComments(questionId):
            return "comments/get/quiz_question/\(questionId)"
        case .getSchools, .postSchool, .schoolPatch:
            return "schools/"
        case .schoolsLogin:
            return "schools/login"
        }
    }

    override var baseUrl: String {
        return APIConstants.baseURL
    }

    override var parameters: Parameters? {
        switch endpoint {
        case let .signUP(params), let .questions(_, params), let .quizAnswer(params), let .addComment(params), let .postSchool(params), let .schoolsLogin(params), let .schoolPatch(params):
            return params
        case .getUser, .assignments, .quizzes, .assignment, .quizze, .login, .getComments, .getSchools:
            return nil
        }
    }

    override var encoding: ParameterEncoding? {
        switch endpoint {
        case let .login(encoding):
            return encoding
        default:
            break
        }
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}
