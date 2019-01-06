//
//  Comment.swift
//  Versus
//
//  Created by JT Smrdel on 7/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

@objcMembers
class Comment: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    private(set) var _competitionEntryId: String?
    private(set) var _competitionId: String?
    private(set) var _createDate: String?
    private(set) var _commentId: String?
    private(set) var _likeCount: NSNumber?
    private(set) var _message: String?
    private(set) var _userId: String?
    private(set) var _username: String?
    
    
    convenience init(
        competitionEntryId: String,
        message: String,
        userId: String,
        username: String
    ) {
        self.init()
        
        _competitionEntryId = competitionEntryId
        _createDate = Date().toISO8601String
        _commentId = UUID().uuidString
        _likeCount = 0.toNSNumber
        _message = message
        _userId = userId
        _username = username
    }
    
    
    class func dynamoDBTableName() -> String {
        
        return "AWS_Comment"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_competitionEntryId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_createDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_competitionEntryId" : "competitionEntryId",
            "_competitionId" : "competitionId",
            "_createDate" : "createDate",
            "_commentId" : "commentId",
            "_likeCount" : "likeCount",
            "_message" : "message",
            "_userId" : "userId",
            "_username" : "username",
        ]
    }
}

extension Comment {
    
    
    var userId: String {
        return _userId ?? ""
    }
    
    
    var username: String {
        return _username ?? ""
    }
    
    
    var message: String {
        return _message ?? ""
    }
    
    
    var createDate: Date {
        return (_createDate ?? "").toISO8601Date
    }
}
