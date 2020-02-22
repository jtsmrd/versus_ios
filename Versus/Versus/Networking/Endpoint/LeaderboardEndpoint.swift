//
//  LeaderboardEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 2/21/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

enum LeaderboardEndpoint {
    case getLeaderboards
}

extension LeaderboardEndpoint: EndpointType {
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        
        switch self {
            
        case .getLeaderboards:
            return "api/leaderboards"
        }
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .getLeaderboards:
            return .get
        }
    }
    
    var task: HTTPTask {
        
        switch self {
            
        case .getLeaderboards:
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
