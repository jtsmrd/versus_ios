//
//  FollowedUserService.swift
//  Versus
//
//  Created by JT Smrdel on 8/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class FollowedUserService {
    
    static let instance = FollowedUserService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    
    private init() { }
    
    
    /**
     
     */
    func follow(
        userId: String,
        username: String,
        displayName: String,
        completion: @escaping (_ followedUser: FollowedUser?, _ customError: CustomError?) -> Void
    ) {
        let awsFollowedUser: AWSFollowedUser = AWSFollowedUser()
        awsFollowedUser._createDate = Date().toISO8601String
        awsFollowedUser._displayName = displayName
        awsFollowedUser._followedUserUserId = userId
        awsFollowedUser._followerDisplayName = CurrentUser.displayName
        awsFollowedUser._followerUsername = CurrentUser.username
        awsFollowedUser._searchDisplayName = displayName.lowercased()
        awsFollowedUser._searchUsername = username.lowercased()
        awsFollowedUser._userId = CurrentUser.userId
        awsFollowedUser._username = username
        
        dynamoDB.save(
            awsFollowedUser
        ) { (error) in
            if let error = error {
                completion(nil, CustomError(error: error, message: "Unable to follow user"))
                return
            }
            completion(FollowedUser(awsFollowedUser: awsFollowedUser), nil)
        }
    }
    
    
    /**
     
     */
    func getFollowedUsers(
        userId: String,
        completion: @escaping (_ followedUsers: [FollowedUser], _ error: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId"
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId
        ]
        
        var followedUsers = [FollowedUser]()
        dynamoDB.query(
            AWSFollowedUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(followedUsers, CustomError(error: error, message: "Unable to get followed users"))
                return
            }
            if let result = paginatedOutput,
                let awsFollowedUsers = result.items as? [AWSFollowedUser] {
                for awsFollowedUser in awsFollowedUsers {
                    followedUsers.append(FollowedUser(awsFollowedUser: awsFollowedUser))
                }
            }
            completion(followedUsers, nil)
        }
    }
    
    
    /**
     
     */
    func unfollow(
        followedUser: FollowedUser,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        dynamoDB.remove(
            followedUser.awsFollowedUser
        ) { (error) in
            if let error = error {
                completion(CustomError(error: error, message: "Unable to unfollow user"))
                return
            }
            completion(nil)
        }
    }
}
