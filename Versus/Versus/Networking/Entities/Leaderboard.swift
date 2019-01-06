//
//  Leaderboard.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

enum LeaderboardType: Int {
    case unknown = 0
    case weekly = 1
    case monthly = 2
    case allTime = 3
}

class Leaderboard: Codable {
    
    private var _isActiveInt: Int = 0
    private var _leaderboardTypeId: Int = 0
    private var _name: String = ""
    private var _numberOfResults: Int = 0
}

extension Leaderboard {
    
    
    var isActive: Bool {
        return Bool(truncating: _isActiveInt as NSNumber)
    }
    
    
    var leaderboardType: LeaderboardType {
        return LeaderboardType(rawValue: _leaderboardTypeId) ?? .unknown
    }
    
    
    var name: String {
        return _name
    }
}
