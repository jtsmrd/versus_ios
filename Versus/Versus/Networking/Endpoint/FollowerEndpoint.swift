//
//  FollowerEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 3/21/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import Foundation

enum FollowerEndpoint {
    case followUser(userId: Int)
    case getFollowedUser(userId: Int, followedUserId: Int)
    case loadFollowedUsers(userId: Int)
    case loadFollowers(userId: Int)
    case unfollow(followerId: Int)
}

extension FollowerEndpoint: EndpointType {
    
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    
    var path: String {
        // Get the follower record, then delete
        switch self {
            
        case .followUser:
            return "api/followers"
            
        case .getFollowedUser(let userId, _):
            return "api/users/\(userId)/followed_users"
            
        case .loadFollowedUsers(let userId):
            return "api/users/\(userId)/followed_users"
            
        case .loadFollowers(let userId):
            return "api/users/\(userId)/followers"
            
        case .unfollow(let followerId):
            return "api/followers/\(followerId)"
        }
    }
    
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .followUser:
            return .post
            
        case .getFollowedUser:
            return .get
            
        case .loadFollowedUsers:
            return .get
            
        case .loadFollowers:
            return .get
            
        case .unfollow:
            return .delete
        }
    }
    
    
    var task: HTTPTask {
        
        switch self {
            
        case .followUser(let userId):
            return .requestParametersAndHeaders(
                bodyParameters: [
                    "followedUser": "/api/users/\(userId)"
                ],
                urlParameters: nil,
                additionalHeaders: headers
            )
            
        case .getFollowedUser(_, let followedUserId):
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: ["followedUser.id": followedUserId],
                additionalHeaders: headers
            )
            
        case .loadFollowedUsers:
            return .request(additionalHeaders: headers)
            
        case .loadFollowers:
            return .request(additionalHeaders: headers)
            
        case .unfollow:
            return .request(additionalHeaders: headers)
        }
    }
    
    
    var headers: HTTPHeaders? {
        return [
            "Authorization": "Bearer \(CurrentAccount.token)",
            "Accept": "application/json"
        ]
    }
}
