//
//  AWSWeeklyLeader.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class AWSWeeklyLeader: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userPoolUserId: String?
    var _weekYear: NSNumber?
    var _createDate: String?
    var _totalVotesDuringWeek: NSNumber?
    var _totalWinsDuringWeek: NSNumber?
    var _updateDate: String?
    var _username: String?
    
    class func dynamoDBTableName() -> String {

        return "versus-mobilehub-387870640-AWS_WeeklyLeader"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userPoolUserId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_weekYear"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userPoolUserId" : "userPoolUserId",
               "_weekYear" : "weekYear",
               "_createDate" : "createDate",
               "_totalVotesDuringWeek" : "totalVotesDuringWeek",
               "_totalWinsDuringWeek" : "totalWinsDuringWeek",
               "_updateDate" : "updateDate",
               "_username" : "username",
        ]
    }
}
