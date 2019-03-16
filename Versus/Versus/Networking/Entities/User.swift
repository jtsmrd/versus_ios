//
//  User.swift
//  Versus
//
//  Created by JT Smrdel on 4/12/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class User: Codable {
    
    private var _bio: String?
    private var _email: String?
    private var _featured: Bool?
    private var _followedUserCount: Int?
    private var _followerCount: Int?
    private var _id: Int?
    private var _name: String?
    private var _rankId: Int?
    private var _totalTimesVoted: Int?
    private var _totalWins: Int?
    private var _updateDate: Date?
    private var _username: String?
    
    enum CodingKeys: String, CodingKey {
        case _bio = "bio"
        case _email = "email"
        case _featured = "featured"
        case _followedUserCount = "followedUserCount"
        case _followerCount = "followerCount"
        case _id = "id"
        case _name = "name"
        case _rankId = "rank_id"
        case _totalTimesVoted = "totalTimesVoted"
        case _totalWins = "totalWins"
        case _updateDate = "update_date"
        case _username = "username"
    }
}

extension User {
    
    
    var bio: String {
        return _bio ?? ""
    }
    
    
    var name: String {
        return _name ?? ""
    }
    
    
    var followedUserCount: Int {
        return _followedUserCount ?? 0
    }
    
    
    var followerCount: Int {
        return _followerCount ?? 0
    }
    
    
    var featured: Bool {
        return _featured ?? false
    }
    
    
    var rank: Rank {
        return RankCollection.instance.rankFor(rankId: rankId)
    }
    
    
    var rankId: Int {
        return _rankId ?? 1
    }
    
    
    var totalTimesVoted: Int {
        return _totalTimesVoted ?? 0
    }
    
    
    var totalWins: Int {
        return _totalWins ?? 0
    }
    
    
    var id: Int {
        return _id ?? -1
    }
    
    
    var username: String {
        return _username ?? ""
    }
}
