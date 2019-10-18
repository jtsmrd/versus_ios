//
//  CompetitionEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 3/24/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

enum CompetitionEndpoint {
    case getCompetition(competitionId: Int)
    case loadFeaturedCompetitions(categoryId: Int?)
    case loadFollowedUserCompetitions(userId: Int)
    case loadUserCompetitions(userId: Int)
}

extension CompetitionEndpoint: EndpointType {
    
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    
    var path: String {
        
        switch self {
            
        case .getCompetition(let competitionId):
            return "api/competitions/\(competitionId)"
            
        case .loadFeaturedCompetitions:
            return "api/competitions"
        
        case .loadFollowedUserCompetitions(let userId):
            return "api/users/\(userId)/followed_user_competitions"
            
        case .loadUserCompetitions(let userId):
            return "api/users/\(userId)/competitions"
        }
    }
    
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .getCompetition:
            return .get
            
        case .loadFeaturedCompetitions:
            return .get
            
        case .loadFollowedUserCompetitions:
            return .get
            
        case .loadUserCompetitions:
            return .get
        }
    }
    
    
    var task: HTTPTask {
        
        switch self {
            
        case .getCompetition:
            return .request(additionalHeaders: headers)
            
        case .loadFeaturedCompetitions(let categoryId):
            
            if let categoryId = categoryId {
                
                return .requestParametersAndHeaders(
                    bodyParameters: nil,
                    urlParameters: [
                        "categoryId": categoryId,
                        "featured": 1
                    ],
                    additionalHeaders: headers
                )
            }
            
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: [
                    "featured": 1
                ],
                additionalHeaders: headers
            )
            
        case .loadFollowedUserCompetitions:
            return .request(additionalHeaders: headers)
            
        case .loadUserCompetitions:
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
