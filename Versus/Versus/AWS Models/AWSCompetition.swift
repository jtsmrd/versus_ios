//
//  AWSCompetition.swift
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
class AWSCompetition: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _categoryId: NSNumber?
    var _competitionTypeId: NSNumber?
    var _expireDate: String?
    var _isFeatured: NSNumber?
    var _startDate: String?
    var _status: String?
    var _user1CompetitionEntryId: String?
    var _user1ImageId: String?
    var _user1ImageSmallId: String?
    var _user1RankId: NSNumber?
    var _user1Username: String?
    var _user1VideoId: String?
    var _user1VideoPreviewImageId: String?
    var _user1VideoPreviewImageSmallId: String?
    var _user1userPoolUserId: String?
    var _user2CompetitionEntryId: String?
    var _user2ImageId: String?
    var _user2ImageSmallId: String?
    var _user2RankId: NSNumber?
    var _user2Username: String?
    var _user2VideoId: String?
    var _user2VideoPreviewImageId: String?
    var _user2VideoPreviewImageSmallId: String?
    var _user2userPoolUserId: String?
    
    class func dynamoDBTableName() -> String {

        return "versus-mobilehub-387870640-AWS_Competition"
    }
    
    class func hashKeyAttribute() -> String {

        return "_id"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_id" : "id",
               "_categoryId" : "categoryId",
               "_competitionTypeId" : "competitionTypeId",
               "_expireDate" : "expireDate",
               "_isFeatured" : "isFeatured",
               "_startDate" : "startDate",
               "_status" : "status",
               "_user1CompetitionEntryId" : "user1CompetitionEntryId",
               "_user1ImageId" : "user1ImageId",
               "_user1ImageSmallId" : "user1ImageSmallId",
               "_user1RankId" : "user1RankId",
               "_user1Username" : "user1Username",
               "_user1VideoId" : "user1VideoId",
               "_user1VideoPreviewImageId" : "user1VideoPreviewImageId",
               "_user1VideoPreviewImageSmallId" : "user1VideoPreviewImageSmallId",
               "_user1userPoolUserId" : "user1userPoolUserId",
               "_user2CompetitionEntryId" : "user2CompetitionEntryId",
               "_user2ImageId" : "user2ImageId",
               "_user2ImageSmallId" : "user2ImageSmallId",
               "_user2RankId" : "user2RankId",
               "_user2Username" : "user2Username",
               "_user2VideoId" : "user2VideoId",
               "_user2VideoPreviewImageId" : "user2VideoPreviewImageId",
               "_user2VideoPreviewImageSmallId" : "user2VideoPreviewImageSmallId",
               "_user2userPoolUserId" : "user2userPoolUserId",
        ]
    }
}
