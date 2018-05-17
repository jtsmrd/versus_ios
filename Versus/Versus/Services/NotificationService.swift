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
    
    
    func getCurrentUserNotifications(completion: @escaping SuccessErrorCompletion) {
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#notifyUserPoolUserId = :notifyUserPoolUserId"
        queryExpression.expressionAttributeNames = [
            "#notifyUserPoolUserId": "notifyUserPoolUserId"
        ]
        queryExpression.expressionAttributeValues = [
            ":notifyUserPoolUserId": CurrentUser.userPoolUserId
        ]
        queryExpression.indexName = "notifyUserPoolUserIdIndex"
        
        var notifications = [Notification]()
        
        AWSDynamoDBObjectMapper.default().query(
            AWSNotification.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user notifications: \(error.localizedDescription)")
                completion(false, CustomError(error: error, title: "", desc: "Unable to load user notifications"))
            }
            else if let result = paginatedOutput {
                if let awsNotifications = result.items as? [AWSNotification] {
                    for awsNotification in awsNotifications {
                        notifications.append(Notification(awsNotification: awsNotification))
                    }
                    CurrentUser.notifications = notifications
                }
                completion(true, nil)
            }
        }
    }
}
