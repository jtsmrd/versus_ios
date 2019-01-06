//
//  Notification.swift
//  Versus
//
//  Created by JT Smrdel on 1/5/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import AWSDynamoDB

enum NotificationType: Int {
    case unknown = 0
    case follower = 1
    case rankUp = 2
    case competitionStarted = 3
    case competitionWon = 4
    case competitionLost = 5
    case competitionComment = 6
    case competitionRemoved = 7
}

@objcMembers
class Notification: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    private(set) var _userId: String?
    private(set) var _createDate: String?
    private(set) var _notificationId: String?
    private(set) var _notificationInfo: [String: String]?
    private(set) var _notificationTypeId: NSNumber?
    var _wasViewed: NSNumber?
    
    
    class func dynamoDBTableName() -> String {
        
        return "AWS_Notification"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_createDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_createDate" : "createDate",
            "_notificationId" : "notificationId",
            "_notificationInfo" : "notificationInfo",
            "_notificationTypeId" : "notificationTypeId",
            "_wasViewed" : "wasViewed",
        ]
    }
}

extension Notification {
    
    
    var userId: String {
        return _userId ?? ""
    }
    
    
    var createDate: Date {
        let createDateString = _createDate ?? ""
        return createDateString.toISO8601Date
    }
    
    
    var notificationId: String {
        return _notificationId ?? ""
    }
    
    
    var wasViewed: Bool {
        return _wasViewed?.boolValue ?? false
    }
    
    
    var notificationInfo: Any {
        get {
            let info = _notificationInfo ?? [:]
            return parseNotificationInfo(info: info)
        }
    }
    
    
    var notificationTypeId: Int {
        return _notificationTypeId?.intValue ?? 0
    }
    
    
    var notificationType: NotificationType {
        return NotificationType(rawValue: notificationTypeId) ?? .unknown
    }
    
    
    
    private func parseNotificationInfo(info: [String: String]) -> Any {
        
        switch notificationType {
            
        case .follower:
            return FollowerNotificationInfo(info: info)
            
        case .rankUp:
            return RankUpNotificationInfo(info: info)
    case .competitionStarted, .competitionWon, .competitionLost, .competitionComment, .competitionRemoved:
            return CompetitionNotificationInfo(info: info)
        default:
            return 0
        }
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
