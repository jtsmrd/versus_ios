//
//  NotificationManager.swift
//  Versus
//
//  Created by JT Smrdel on 6/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class NotificationManager {
    
    static let instance = NotificationManager()
    
    var notifications = [Notification]()
    
    private init() { }
    
    /*
     Gets Notification records for the current user. Also stores results locally in NotificationManager instance.
     */
//    func getCurrentUserNotifications(completion: @escaping (_ notifications: [Notification], _ error: CustomError?) -> Void) {
//
//        NotificationService.instance.getCurrentUserNotifications { (notifications, customError) in
//            if let customError = customError {
//                completion(self.notifications, customError)
//            }
//            else {
//
//                // Don't add Notifications that already exist
//                for notification in notifications {
//                    if !self.notifications.contains(where: { $0 == notification }) {
//                        self.notifications.append(notification)
//                    }
//                }
//                completion(self.notifications, nil)
//            }
//        }
//    }
    
    
    /*
     Removes the given Notification record from the stored collection. Used after deleting notificaiton from the database.
    */
    func removeNotification(notification: Notification) {
        if let index = notifications.firstIndex(where: { $0 === notification }) {
            notifications.remove(at: index)
        }
    }
}
