//
//  Follower.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

enum FollowStatus {
    case following
    case notFollowing
}

class Follower: Codable {
    
    private var _id: Int
    private var _createDate: Date
    private var _inviteAccepted: Bool
    private var _user: User
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _createDate = "createDate"
        case _inviteAccepted = "inviteAccepted"
        case _user = "follower"
    }
}

extension Follower {
    
    
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

extension Follower: Equatable {
    
    static func == (lhs: Follower, rhs: Follower) -> Bool {
        return lhs.id == rhs.id
    }
}
