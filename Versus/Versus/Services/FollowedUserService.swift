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
        displayName: String,
        followedUserUserId: String,
        followerDisplayName: String,
        followerUsername: String,
        searchDisplayName: String,
        searchUsername: String,
        username: String,
        userId: String,
        completion: @escaping (_ followedUser: FollowedUser?, _ customError: CustomError?) -> Void
    ) {
        
        let followedUser = FollowedUser(
            displayName: displayName,
            followedUserUserId: followedUserUserId,
            followerDisplayName: followerDisplayName,
            followerUsername: followerUsername,
            searchDisplayName: searchDisplayName,
            searchUsername: searchUsername,
            username: username,
            userId: userId
        )
        
        dynamoDB.save(
            followedUser
        ) { (error) in
            if let error = error {
                completion(nil, CustomError(error: error, message: "Unable to follow user"))
                return
            }
            completion(followedUser, nil)
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
            FollowedUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(followedUsers, CustomError(error: error, message: "Unable to get followed users"))
                return
            }
            if let result = paginatedOutput,
                let followedUserResults = result.items as? [FollowedUser] {
                for item in followedUserResults {
                    followedUsers.append(item)
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
            followedUser
        ) { (error) in
            if let error = error {
                completion(CustomError(error: error, message: "Unable to unfollow user"))
                return
            }
            completion(nil)
        }
    }
}
