//
//  NotificationService.swift
//  Versus
//
//  Created by JT Smrdel on 5/16/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class NotificationService {
    
    static let instance = NotificationService()
    
    private let networkManager = NetworkManager()
    private let router = Router<NotificationEndpoint>()
    
    private init() { }
    
    
    func getUserNotifications(
        userId: Int,
        page: Int,
        completion: @escaping (_ notifications: [Notification], _ error: String?) -> ()
    ) {
        router.request(
            .loadNotifications(
                userId: userId,
                page: page
            )
        ) { (data, response, error) in
            
            var notifications = [Notification]()
            
            if error != nil {
                completion(
                    notifications,
                    "Please check your network connection."
                )
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(
                            notifications,
                            NetworkResponse.noData.rawValue
                        )
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        notifications = try decoder.decode(
                            [Notification].self,
                            from: responseData
                        )
                        completion(notifications, nil)
                    }
                    catch {
                        completion(
                            notifications,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    completion(notifications, networkFailureError)
                }
            }
        }
    }
    
    
    func setNotificationViewed(
        notification: Notification,
        completion: @escaping (_ notification: Notification?, _ error: String?) -> ()
    ) {
        router.request(
            .setNotificationViewed(notification)
        ) { (data, response, error) in
            
            if error != nil {
                completion(
                    nil,
                    "Please check your network connection."
                )
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(
                            nil,
                            NetworkResponse.noData.rawValue
                        )
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let notification = try decoder.decode(
                            Notification.self,
                            from: responseData
                        )
                        completion(notification, nil)
                    }
                    catch {
                        completion(
                            nil,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func deleteNotification(
        notification: Notification,
        completion: @escaping (_ error: String?) -> ()
    ) {
        router.request(
            .deleteNotification(
                id: notification.id
            )
        ) { (data, response, error) in
            
            if error != nil {
                completion(
                    "Please check your network connection."
                )
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    completion(nil)
                    
                case .failure(let networkFailureError):
                    completion(networkFailureError)
                }
            }
        }
    }
}
