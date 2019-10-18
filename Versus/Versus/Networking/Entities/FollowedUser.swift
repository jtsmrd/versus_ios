//
//  FollowedUser.swift
//  Versus
//
//  Created by JT Smrdel on 8/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class FollowedUser: Codable {
    
    private var _id: Int
    private var _createDate: Date
    private var _inviteAccepted: Bool
    private var _user: User
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _createDate = "createDate"
        case _inviteAccepted = "inviteAccepted"
        case _user = "followedUser"
    }
}

extension FollowedUser {
    
    
    var createDate: Date {
        return _createDate
    }
    
    
    var id: Int {
        return _id
    }
    
    
    var inviteAccepted: Bool {
        return _inviteAccepted
    }
    
    
    var user: User {
        return _user
    }
}
