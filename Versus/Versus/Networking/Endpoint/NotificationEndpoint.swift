//
//  NotificationEndpoint.swift
//  Versus
//
//  Created by JT Smrdel on 3/7/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import Foundation

enum NotificationEndpoint {
    case loadNotifications(userId: Int, page: Int)
    case setNotificationViewed(Notification)
    case deleteNotification(id: Int)
}

extension NotificationEndpoint: EndpointType {
    
    var baseURL: URL {
        
        guard let url = URL(string: Config.BASE_URL) else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        
        switch self {
            
        case .loadNotifications(let userId, _):
            return "api/users/\(userId)/notifications"
            
        case .setNotificationViewed(let notification):
            return "api/notifications/\(notification.id)"
            
        case .deleteNotification(let id):
            return "api/notifications/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
            
        case .loadNotifications:
            return .get
            
        case .setNotificationViewed:
            return .put
            
        case .deleteNotification:
            return .delete
        }
    }
    
    var task: HTTPTask {
        
        switch self {
            
        case .loadNotifications(_, let page):
            return .requestParametersAndHeaders(
                bodyParameters: nil,
                urlParameters: [
                    "page": page
                ],
                additionalHeaders: headers
            )
            
        case .setNotificationViewed:
            return .requestParametersAndHeaders(
                bodyParameters: [
                    "wasViewed": true
                ],
                urlParameters: nil,
                additionalHeaders: headers
            )
            
        case .deleteNotification:
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
