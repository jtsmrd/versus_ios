//
//  CompetitionEntryEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 1/6/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

enum NetworkEnvironment {
    case dev
    case qa
    case stage
    case prod
}

enum CompetitionEntryEndpoint {
    case create(CompetitionEntry)
    case delete
    case unmatched(userId: String)
    case update
}

extension CompetitionEntryEndpoint: EndpointType {
    
    
    var environmentBaseURL: String {
        
        switch NetworkManager.environment {
        case .dev:
            return "http://192.168.1.7/versus/v1/"
        case .qa:
            return ""
        case .stage:
            return ""
        case .prod:
            return ""
        }
    }
    
    
    var baseURL: URL {
        
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    
    var path: String {
        
        switch self {
            
        case .create:
            return "competitionEntry"
            
        case .delete:
            return "competitionEntry"
            
        case .unmatched:
            return "competitionEntry"
            
        case .update:
            return "competitionEntry"
        }
    }
    
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .create:
            return .post
            
        case .delete:
            return .delete
            
        case .unmatched:
            return .get
            
        case .update:
            return .patch
        }
    }
    
    
    var task: HTTPTask {
        
        switch self {
            
        case .create:
            return .request
            
        case .delete:
            return .request
            
        case .unmatched(let userId):
            return .requestParameters(bodyParameters: nil, urlParameters: ["id": userId])
            
        case .update:
            return .request
        }
    }
    
    
    var headers: HTTPHeaders? {
        return nil
    }
}
