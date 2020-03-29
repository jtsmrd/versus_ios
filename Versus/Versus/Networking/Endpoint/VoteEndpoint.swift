//
//  VoteEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 12/26/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import Foundation

enum VoteEndpoint {
    case create(
        entryId: Int,
        competitionId: Int
    )
    case delete(
        voteId: Int
    )
    case get(
        competitionId: Int
    )
    case update(
        voteId: Int,
        entryId: Int
    )
}

extension VoteEndpoint: EndpointType {
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    
    var path: String {
        
        switch self {
            
        case .create:
            return "api/votes"
            
        case .delete(let voteId):
            return String(
                format: "api/votes/%d",
                voteId
            )
            
        case .get(let competitionId):
            return String(
                format: "api/get-user-vote/%d",
                competitionId
            )
            
        case .update(let voteId, _):
            return String(
                format: "api/votes/%d",
                voteId
            )
        }
    }
    
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .create:
            return .post
            
        case .delete:
            return .delete
            
        case .get:
            return .get
            
        case .update:
            return .put
        }
    }
    
    
    var task: HTTPTask {
        
        switch self {
            
        case .create(
            let entryId,
            let competitionId
        ):
            return .requestParametersAndHeaders(
                bodyParameters: [
                    "entry": String(
                        format: "/api/entries/%d",
                        entryId
                    ),
                    "competition": String(
                        format: "/api/competitions/%d",
                        competitionId
                    )
                ],
                urlParameters: nil,
                additionalHeaders: headers
            )
            
        case .delete:
            return .request(additionalHeaders: headers)
            
        case .get:
            return .request(additionalHeaders: headers)
            
        case .update(
            _,
            let entryId
        ):
            return .requestParametersAndHeaders(
                bodyParameters: [
                    "entry": String(format: "/api/entries/%d", entryId)
                ],
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
