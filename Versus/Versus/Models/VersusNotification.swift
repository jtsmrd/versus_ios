//
//  VersusNotification.swift
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

class VersusNotification {
    
    private let notificationService = NotificationService.instance
    
    private let awsNotification: AWSNotification!
    
    var userId: String
    var createDate: Date
    var notificationId: String
    var notificationInfoDictionary: [String: String]
    var notificationTypeId: Int
    var wasViewed: Bool {
        return awsNotification._wasViewed?.boolValue ?? false
    }
    
    var notificationInfo: Any!
    var notificationType: NotificationType {
        return NotificationType(rawValue: notificationTypeId)!
    }
    
    
    /**
 
     */
    init(awsNotification: AWSNotification) {
        self.awsNotification = awsNotification
        
        self.userId = awsNotification._userId ?? ""
        self.createDate = awsNotification._createDate?.toISO8601Date ?? Date()
        self.notificationId = awsNotification._notificationId ?? ""
        self.notificationInfoDictionary = awsNotification._notificationInfo ?? [:]
        self.notificationTypeId = awsNotification._notificationTypeId?.intValue ?? 1
        self.notificationInfo = parseNotificationInfo(info: self.notificationInfoDictionary)
    }
    
    
    /**
     
     */
    private func parseNotificationInfo(info: [String: String]) -> Any {
        switch notificationType {
        case .follower:
            return FollowerNotificationInfo(info: info)
        case .rankUp:
            return RankUpNotificationInfo(info: info)
        case .competitionStarted, .competitionWon, .competitionLost, .competitionComment, .competitionRemoved:
            return CompetitionNotificationInfo(info: info)
        }
    }
    
    
    /**
     
     */
    func markViewed(
        completion: ((_ customError: CustomError?) -> Void)?
    ) {
        notificationService.markNotificationViewed(
            awsNotification: awsNotification,
            completion: completion
        )
    }
    
    
    /**
     
     */
    func delete(
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        notificationService.deleteNotification(
            awsNotification: awsNotification,
            completion: completion
        )
    }
}

extension VersusNotification: Equatable {
    
    static func == (lhs: VersusNotification, rhs: VersusNotification) -> Bool {
        return lhs.notificationId == rhs.notificationId
    }
}

struct FollowerNotificationInfo {
    
    var userId: String
    var username: String
    var notificationText: String
    
    init(info: [String: String]) {
        userId = info["userId"] ?? ""
        username = info["username"] ?? ""
        notificationText = info["notificationText"] ?? ""
    }
}

struct RankUpNotificationInfo {
    
    var newRankId: Int
    var notificationText: String
    
    init(info: [String: String]) {
        newRankId = Int(info["newRankId"]!) ?? 1
        notificationText = info["notificationText"] ?? ""
    }
}

struct CompetitionNotificationInfo {
    
    var userId: String
    var username: String
    var competitionId: String
    var notificationText: String
    
    init(info: [String: String]) {
        userId = info["userId"] ?? ""
        username = info["username"] ?? ""
        competitionId = info["competitionId"] ?? ""
        notificationText = info["notificationText"] ?? ""
    }
}
