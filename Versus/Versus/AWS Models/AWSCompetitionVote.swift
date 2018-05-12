//
//  AWSCompetitionVote.swift
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
class AWSCompetitionVote: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _competitionId: String?
    var _createDate: String?
    var _userPoolUserId: String?
    var _votedForUserPoolUserId: String?
    
    class func dynamoDBTableName() -> String {

        return "versus-mobilehub-387870640-AWS_CompetitionVote"
    }
    
    class func hashKeyAttribute() -> String {

        return "_id"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_id" : "id",
               "_competitionId" : "competitionId",
               "_createDate" : "createDate",
               "_userPoolUserId" : "userPoolUserId",
               "_votedForUserPoolUserId" : "votedForUserPoolUserId",
        ]
    }
}