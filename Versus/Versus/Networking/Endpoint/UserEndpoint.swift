//
//  UserEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 3/2/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import Foundation

enum UserEndpoint {
    case load(userId: Int)
    case loadFollowedUserIds(userId: Int)
    case loadWithUsername(username: String)
    case searchByName(name: String, page: Int)
    case searchByUsername(username: String, page: Int)
    case update(User)
}

extension UserEndpoint: EndpointType {
    
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    
    var path: String {
        
        switch self {
            
        case .load(let userId):
            return "api/users/\(userId)"
            
        case .loadFollowedUserIds(let userId):
            return "api/users/\(userId)/followed_user_ids"
            
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
            
        case .loadFollowedUserIds:
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
            
        case .load:
            return .request(additionalHeaders: headers)
            
        case .loadFollowedUserIds:
            return .request(additionalHeaders: headers)
            
        case .loadWithUsername:
            return .request(additionalHeaders: headers)
            
        case .searchByName(let name, let page):
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: [
                    "name": name,
                    "page": page
                ],
                additionalHeaders: headers
            )
            
        case .searchByUsername(let username, let page):
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: [
                    "username": username,
                    "page": page
                ],
                additionalHeaders: headers
            )
            
        case .update(let user):
            
            var params = [
                "bio": user.bio,
                "name": user.name,
                "profileImage": user.profileImageId,
                "backgroundImage": user.backgroundImage
            ]
            
            if let token = user.apnsToken {
                params["apnsToken"] = token
            }
            
            return .requestParametersAndHeaders(
                bodyParameters: params,
                urlParameters: nil,
                additionalHeaders: headers
            )
        }
    }
    
    
    var headers: HTTPHeaders? {
        return [
            "Authorization": "Bearer \(CurrentAccount.token)",
            "Accept": "application/json"
        ]
    }
}
