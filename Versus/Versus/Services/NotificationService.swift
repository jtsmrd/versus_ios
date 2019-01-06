//
//  NotificationService.swift
//  Versus
//
//  Created by JT Smrdel on 5/16/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class NotificationService {
    
    static let instance = NotificationService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    
    private init() { }
    
    
    /**
 
     */
    func getCurrentUserNotifications(
        completion: @escaping (_ notifications: [Notification], _ error: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId"
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": CurrentUser.userId
        ]
        queryExpression.scanIndexForward = false
        
        var notifications = [Notification]()
        dynamoDB.query(
            Notification.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(notifications, CustomError(error: error, message: "Unable to load user notifications"))
                return
            }
            if let result = paginatedOutput,
                let notificationResults = result.items as? [Notification] {
                for item in notificationResults {
                    notifications.append(item)
                }
            }
            completion(notifications, nil)
        }
    }
    
    
    /**
        Mark notification as viewed.
     */
    func markNotificationViewed(
        notification: Notification,
        completion: ((_ customError: CustomError?) -> Void)?
    ) {
        notification._wasViewed = 1.toNSNumber
        dynamoDB.save(
            notification
        ) { (error) in
            if let error = error {
                notification._wasViewed = 0.toNSNumber
                completion?(CustomError(error: error, message: "Unable to update notification"))
                return
            }
            completion?(nil)
        }
    }
    
    
    /**
        Deletes the Notification record from DynamoDB.
     */
    func deleteNotification(
        notification: Notification,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        dynamoDB.remove(
            notification
        ) { (error) in
            if let error = error {
                completion(CustomError(error: error, message: "Unable to delete notification"))
                return
            }
            completion(nil)
        }
    }
}
