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
    
    private init() { }
    
    
    func getCurrentUserNotifications(completion: @escaping (_ notifications: [Notification], _ error: CustomError?) -> Void) {
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#notifyUserPoolUserId = :notifyUserPoolUserId"
        queryExpression.expressionAttributeNames = [
            "#notifyUserPoolUserId": "notifyUserPoolUserId"
        ]
        queryExpression.expressionAttributeValues = [
            ":notifyUserPoolUserId": CurrentUser.userPoolUserId
        ]
        queryExpression.scanIndexForward = false
        
        var notifications = [Notification]()
        
        AWSDynamoDBObjectMapper.default().query(
            AWSNotification.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user notifications: \(error.localizedDescription)")
                completion(notifications, CustomError(error: error, title: "", desc: "Unable to load user notifications"))
            }
            else if let result = paginatedOutput {
                if let awsNotifications = result.items as? [AWSNotification] {
                    for awsNotification in awsNotifications {
                        notifications.append(Notification(awsNotification: awsNotification))
                    }
                }
                completion(notifications, nil)
            }
        }
    }
    
    
    /// Sets the AWSNotification records' wasViewed flag to true.
    func setNotificationWasViewed(_ notification: Notification, completion: @escaping SuccessErrorCompletion) {
        
        notification.awsNotification._wasViewed = 1.toNSNumber
        
        AWSDynamoDBObjectMapper.default().save(notification.awsNotification) { (error) in
            if let error = error {
                completion(false, CustomError(error: error, title: "", desc: "Unable to update notification."))
            }
            completion(true, nil)
        }
    }
    
    
    /// Deletes the Notification record from DynamoDB.
    func deleteNotification(notification: Notification, completion: @escaping SuccessErrorCompletion) {
        
        AWSDynamoDBObjectMapper.default().remove(notification.awsNotification) { (error) in
            if let error = error {
                completion(false, CustomError(error: error, title: "", desc: "Unable to delete notification"))
            }
            else {
                completion(true, nil)
            }
        }
    }
}
