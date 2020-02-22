//
//  Leader.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class Leader: Codable {
    
    private var _id: Int
    private var _user: User
    private var _winCount: Int
    private var _voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _user = "user"
        case _winCount = "winCount"
        case _voteCount = "voteCount"
    }
}

extension Leader {
    
    var id: Int {
        return _id
    }
    
    var user: User {
        return _user
    }
    
    var winCount: Int {
        return _winCount
    }
    
    var voteCount: Int {
        return _voteCount
    }
}
