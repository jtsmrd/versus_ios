//
//  FollowedUser.swift
//  Versus
//
//  Created by JT Smrdel on 8/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

@objcMembers
class FollowedUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
        
    private(set) var _createDate: String?
    private(set) var _displayName: String?
    private(set) var _followedUserUserId: String?
    private(set) var _followerDisplayName: String?
    private(set) var _followerUsername: String?
    private(set) var _searchDisplayName: String?
    private(set) var _searchUsername: String?
    private(set) var _username: String?
    private(set) var _userId: String?
    
    
    convenience init(
        displayName: String,
        followedUserUserId: String,
        followerDisplayName: String,
        followerUsername: String,
        searchDisplayName: String,
        searchUsername: String,
        username: String,
        userId: String
    ) {
        self.init()
        
        _createDate = Date().toISO8601String
        _displayName = displayName
        _followedUserUserId = followedUserUserId
        _followerDisplayName = followerDisplayName
        _followerUsername = followerUsername
        _searchDisplayName = searchDisplayName
        _searchUsername = searchUsername
        _username = username
        _userId = userId
    }
    
    
    class func dynamoDBTableName() -> String {
        
        return "AWS_FollowedUser"
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
            "_followedUserUserId" : "followedUserUserId",
            "_followerDisplayName" : "followerDisplayName",
            "_followerUsername" : "followerUsername",
            "_searchDisplayName" : "searchDisplayName",
            "_searchUsername" : "searchUsername",
            "_username" : "username",
            "_userId" : "userId",
        ]
    }
}

extension FollowedUser {
    
    
    var username: String {
        return _username ?? ""
    }
    
    
    var followedUserUserId: String {
        return _followedUserUserId ?? ""
    }
    
    
    var displayName: String {
        return _displayName ?? ""
    }
    
    
    var searchUsername: String {
        return _searchUsername ?? ""
    }
    
    
    var searchDisplayName: String {
        return _searchDisplayName ?? ""
    }
}
