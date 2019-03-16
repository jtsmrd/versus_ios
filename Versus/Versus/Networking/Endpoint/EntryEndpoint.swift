//
//  EntryEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 1/6/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

enum EntryEndpoint {
    case create(
        caption: String,
        categoryId: Int,
        typeId: Int,
        mediaId: String
    )
    case delete
    case unmatched(id: Int)
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
            return "api/entries"
            
        case .delete:
            return ""
            
        case .unmatched:
            return ""
            
        case .update:
            return ""
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
            
        case .create(
            let caption,
            let categoryId,
            let typeId,
            let mediaId
        ):
            return .requestParametersAndHeaders(
                bodyParameters: [
                    "caption": caption,
                    "categoryId": categoryId,
                    "typeId": typeId,
                    "mediaId": mediaId
                ],
                urlParameters: nil,
                additionalHeaders: headers
            )
            
        case .delete:
            return .request
            
        case .unmatched(let id):
            return .requestParameters(
                bodyParameters: nil,
                urlParameters: [
                    "id": id
                ]
            )
            
        case .update:
            return .request
        }
    }
    
    
    var headers: HTTPHeaders? {
        return ["Authorization": "Bearer \(CurrentAccount.token)"]
    }
}
