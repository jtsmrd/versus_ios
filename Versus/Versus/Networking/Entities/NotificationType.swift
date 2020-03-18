//
//  NotificationType.swift
//  Versus
//
//  Created by JT Smrdel on 3/7/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import Foundation

enum NotificationTypeEnum: String {
    case newFollower = "New Follower"
    case competitionMatched = "Competition Matched"
    case newVote = "New Vote"
    case competitionWon = "Competition Won"
    case competitionLost = "Competition Lost"
    case rankUp = "Rank Up"
    case leaderboard = "Leaderboard"
    case topLeader = "Top Leader"
    case newFollowedUserCompetition = "New Followed User Competition"
    case newComment = "New Comment"
    case newDirectMessage = "New Direct Message"
}

class NotificationType: Codable {

    private var _id: Int
    private var _name: String

    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
    }
}

extension NotificationType {
    
    var id: Int {
        return _id
    }
    
    var name: String {
        return _name
    }
    
    var typeEnum: NotificationTypeEnum {
        return NotificationTypeEnum(rawValue: name)!
    }
}
