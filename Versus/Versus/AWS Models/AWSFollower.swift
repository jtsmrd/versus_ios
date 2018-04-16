//
//  AWSFollower.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.19
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class AWSFollower: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _createDate: String?
    var _followedUserDisplayName: String?
    var _followedUserId: String?
    var _followedUserUsername: String?
    var _followerDisplayName: String?
    var _followerUserId: String?
    var _followerUsername: String?
    
    class func dynamoDBTableName() -> String {

        return "versus-mobilehub-387870640-AWS_Follower"
    }
    
    class func hashKeyAttribute() -> String {

        return "_id"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_id" : "id",
               "_createDate" : "createDate",
               "_followedUserDisplayName" : "followedUserDisplayName",
               "_followedUserId" : "followedUserId",
               "_followedUserUsername" : "followedUserUsername",
               "_followerDisplayName" : "followerDisplayName",
               "_followerUserId" : "followerUserId",
               "_followerUsername" : "followerUsername",
        ]
    }
}
