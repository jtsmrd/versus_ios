//
//  AccountEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 3/10/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

enum AccountEndpoint {
    case create(
        name: String,
        email: String,
        username: String,
        password: String,
        retypedPassword: String
    )
    case login(
        username: String,
        password: String
    )
    case usernameAvailable(username: String)
}

extension AccountEndpoint: EndpointType {
    
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        
        switch self {
            
        case .create:
            return "api/users"
            
        case .login:
            return "api/login_check"
            
        case .usernameAvailable(let username):
            return "username_available/\(username)"
        }
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .create:
            return .post
            
        case .login:
            return .post
            
        case .usernameAvailable:
            return .get
        }
    }
    
    var task: HTTPTask {
        
        switch self {
            
        case .create(
            let name,
            let email,
            let username,
            let password,
            let retypedPassword
            ):
            return .requestParameters(
                bodyParameters: [
                    "name": name,
                    "email": email,
                    "username": username,
                    "password": password,
                    "retypedPassword": retypedPassword
                ],
                urlParameters: nil
            )
            
        case .login(
            let username,
            let password
            ):
            return .requestParameters(
                bodyParameters: [
                    "username": username,
                    "password": password
                ],
                urlParameters: nil
            )
            
        case .usernameAvailable:
            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return ["Authorization": "Bearer \(CurrentAccount.token)"]
    }
}
