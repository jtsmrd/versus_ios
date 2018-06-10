//
//  AWSUserSNSEndpointARN.swift
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
class AWSUserSNSEndpointARN: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userPoolUserId: String?
    var _endpointArn: String?
    
    class func dynamoDBTableName() -> String {

        return "versus-mobilehub-387870640-AWS_UserSNSEndpointARN"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userPoolUserId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userPoolUserId" : "userPoolUserId",
               "_endpointArn" : "endpointArn",
        ]
    }
}