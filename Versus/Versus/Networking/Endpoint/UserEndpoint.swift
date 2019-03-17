//
//  UserEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 3/2/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

enum UserEndpoint {
    case load(userId: Int)
    case loadWithUsername(username: String)
    case searchByName(name: String)
    case searchByUsername(username: String)
    case update(User)
}

extension UserEndpoint: EndpointType {
    
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    
    var path: String {
        
        switch self {
            
        case .load:
            return ""
            
        case .loadWithUsername(let username):
            return "api/users/username/\(username)"
            
        case .searchByName:
            return "api/users"
            
        case .searchByUsername:
            return "api/users"
            
        case .update(let user):
            return "api/users/\(user.id)"
        }
    }
    
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .load:
            return .get
            
        case .loadWithUsername:
            return .get
            
        case .searchByName:
            return .get
            
        case .searchByUsername:
            return .get
            
        case .update:
            return .put
        }
    }
    
    
    var task: HTTPTask {
        
        switch self {
            
        case .load(let userId):
            return .requestParameters(
                bodyParameters: nil,
                urlParameters: [
                    "userId": userId
                ]
            )
            
        case .loadWithUsername:
            return .request
            
        case .searchByName(let name):
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: [
                    "name": name
                ],
                additionalHeaders: headers
            )
            
        case .searchByUsername(let username):
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: [
                    "username": username
                ],
                additionalHeaders: headers
            )
            
        case .update(let user):
            return .requestParametersAndHeaders(
                bodyParameters: [
                    "bio": user.bio,
                    "name": user.name,
                    "profileImage": user.profileImage,
                    "backgroundImage": user.backgroundImage
                ],
                urlParameters: nil,
                additionalHeaders: headers
            )
        }
    }
    
    
    var headers: HTTPHeaders? {
        return ["Authorization": "Bearer \(CurrentAccount.token)"]
    }
}
