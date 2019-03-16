//
//  EntryEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 1/6/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

enum EntryEndpoint {
    case create(Entry)
    case delete
    case unmatched(userId: String)
    case update
}

extension EntryEndpoint: EndpointType {
    
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else { fatalError("baseURL could not be configured.")}
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
