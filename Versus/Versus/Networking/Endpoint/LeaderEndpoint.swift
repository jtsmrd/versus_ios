//
//  LeaderEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 2/15/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import Foundation

enum LeaderEndpoint {
    case getWeekly
    case getMonthly
    case getAllTime
}

extension LeaderEndpoint: EndpointType {
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        
        switch self {
            
        case .getWeekly:
            return "api/leaders/weekly"
            
        case .getMonthly:
            return "api/leaders/monthly"
            
        case .getAllTime:
            return "api/leaders/alltime"
        }
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .getWeekly:
            return .get
            
        case .getMonthly:
            return .get
            
        case .getAllTime:
            return .get
        }
    }
    
    var task: HTTPTask {
        
        switch self {
            
        case .getWeekly:
            return .request(additionalHeaders: headers)
            
        case .getMonthly:
            return .request(additionalHeaders: headers)
            
        case .getAllTime:
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
