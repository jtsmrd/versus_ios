//
//  Follower.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

enum FollowStatus {
    case following
    case notFollowing
}

@objcMembers
class Follower: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    private(set) var _createDate: String?
    private(set) var _displayName: String?
    private(set) var _followerUserId: String?
    private(set) var _searchDisplayName: String?
    private(set) var _searchUsername: String?
    private(set) var _username: String?
    private(set) var _userId: String?
    
    
    class func dynamoDBTableName() -> String {
        
        return "AWS_Follower"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_createDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_createDate" : "createDate",
            "_displayName" : "displayName",
            "_followerUserId" : "followerUserId",
            "_searchDisplayName" : "searchDisplayName",
            "_searchUsername" : "searchUsername",
            "_username" : "username",
            "_userId" : "userId",
        ]
    }
}

extension Follower {
    
    
    var displayName: String {
        return _displayName ?? ""
    }
    
    
    var followerUserId: String {
        return _followerUserId ?? ""
    }
    
    
    var searchDisplayName: String {
        return _searchDisplayName ?? ""
    }
    
    
    var searchUsername: String {
        return _searchUsername ?? ""
    }
    
    
    var username: String {
        return _username ?? ""
    }
}
