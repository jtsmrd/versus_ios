//
//  Notification.swift
//  Versus
//
//  Created by JT Smrdel on 1/5/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

class Notification: Codable {
    
    private var _id: Int
    private var _type: NotificationType
    private var _createDate: Date
    private var _message: String
    private var _payload: String
    private var _wasViewed: Bool
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _type = "type"
        case _createDate = "createDate"
        case _message = "message"
        case _payload = "payload"
        case _wasViewed = "wasViewed"
    }
}

extension Notification {
    
    var id: Int {
        return _id
    }
    
    var type: NotificationType {
        return _type
    }
    
    var createDate: Date {
        return _createDate
    }
    
    var message: String {
        return _message
    }
    
    var wasViewed: Bool {
        return _wasViewed
    }
    
    
    var notificationPayload: Any {
        return parseNotificationPayload(payload: _payload)
    }
    
    
    
    private func parseNotificationPayload(payload: String) -> Any {

        switch type.typeEnum {
            
        case .newFollower:
            return FollowerNotificationInfo(jsonString: payload)
            
        case .competitionMatched:
            return 0
            
        case .newVote:
            return 0
            
        case .competitionWon:
            return 0
            
        case .competitionLost:
            return 0
            
        case .rankUp:
            return 0
            
        case .leaderboard:
            return 0
            
        case .topLeader:
            return 0
            
        case .newFollowedUserCompetition:
            return 0
            
        case .newComment:
            return 0
            
        case .newDirectMessage:
            return 0
        }
    }
}

class FollowerNotificationInfo: NSObject {
    
    var followerUserId: Int = 0
    var followerUsername: String = ""
    var followerProfileImage: String = ""
    
    init(jsonString: String) {
        super.init()
        
        let jsonData = jsonString.data(
            using: .utf8,
            allowLossyConversion: false
        )
        
        let jsonDictionary: [String: Any] = try! JSONSerialization.jsonObject(
                with: jsonData!,
                options: .init()
            ) as! [String: Any]
        
        followerUserId = jsonDictionary["followerUserId"] as! Int
        followerUsername = jsonDictionary["followerUsername"] as! String
        followerProfileImage = jsonDictionary["followerProfileImage"] as! String
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
    
    var userId: Int
    var username: String
    var competitionId: Int
    var notificationText: String
    
    init(info: [String: Any]) {
        userId = info["userId"] as! Int
        username = info["username"] as! String
        competitionId = info["competitionId"] as! Int
        notificationText = info["notificationText"] as! String
    }
}
