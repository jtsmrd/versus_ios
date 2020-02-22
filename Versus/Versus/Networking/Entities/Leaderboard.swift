//
//  Leaderboard.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class Leaderboard: Codable {
    
    private var _id: Int
    private var _featureImage: String?
    private var _backgroundImage: String?
    private var _type: LeaderboardType
    private var _isActive: Bool
    private var _resultLimit: Int
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _featureImage = "featureImage"
        case _backgroundImage = "backgroundImage"
        case _type = "type"
        case _isActive = "isActive"
        case _resultLimit = "resultLimit"
    }
}

extension Leaderboard {
    
    var id: Int {
        return _id
    }
    
    var featureImage: String? {
        return _featureImage
    }
    
    var backgroundImage: String? {
        return _backgroundImage
    }
    
    var type: LeaderboardType {
        return _type
    }
    
    var isActive: Bool {
        return _isActive
    }
    
    var resultLimit: Int {
        return _resultLimit
    }
}
