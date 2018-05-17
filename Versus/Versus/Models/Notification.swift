//
//  Notification.swift
//  Versus
//
//  Created by JT Smrdel on 5/15/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum NotificationType: Int {
    case follower = 1
    case rankUp = 2
    case competitionStarted = 3
    case competitionWon = 4
    case competitionLost = 5
    case competitionComment = 6
    case competitionRemoved = 7
}

class Notification {
    
    var awsNotification: AWSNotification!
    var notificationInfo: Any!
    var notificationType: NotificationType {
        return NotificationType(rawValue: (awsNotification._notificationTypeId?.intValue)!)!
    }
    
    init(awsNotification: AWSNotification) {
        self.awsNotification = awsNotification
        parseNotificationInfo(info: awsNotification._notificationInfo)
    }
    
    private func parseNotificationInfo(info: [String: String]?) {
        guard let info = info else { return }
        
        switch notificationType {
        case .follower:
            notificationInfo = FollowerNotificationInfo(info: info)
        case .rankUp:
            notificationInfo = RankUpNotificationInfo(info: info)
        case .competitionStarted, .competitionWon, .competitionLost, .competitionComment, .competitionRemoved:
            notificationInfo = CompetitionNotificationInfo(info: info)
        }
    }
}

struct FollowerNotificationInfo {
    
    var followerUserPoolUserId: String!
    var followerUsername: String!
    var notificationText: String!
    
    init(info: [String: String]) {
        followerUserPoolUserId = info["followerUserPoolUserId"]
        followerUsername = info["followerUsername"]
        notificationText = info["notificationText"]
    }
}

struct RankUpNotificationInfo {
    
    var newRankId: Int!
    var notificationText: String!
    
    init(info: [String: String]) {
        newRankId = Int(info["newRankId"]!)
        notificationText = info["notificationText"]
    }
}

struct CompetitionNotificationInfo {
    
    var userPoolUserId: String?
    var username: String?
    var competitionId: String!
    var notificationText: String!
    
    init(info: [String: String]) {
        userPoolUserId = info["userPoolUserId"]
        username = info["username"]
        competitionId = info["competitionId"]
        notificationText = info["notificationText"]
    }
}
