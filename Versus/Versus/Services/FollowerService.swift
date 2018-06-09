//
//  FollowerService.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class FollowerService {
    
    static let instance = FollowerService()
    
    private init() { }
    
    
    
    func followUser(
        userToFollow: User,
        currentUser: User,
        completion: @escaping SuccessErrorCompletion) {
        
        let follower: AWSFollower = AWSFollower()
        follower._id = UUID().uuidString
        follower._createDate = Date().toISO8601String
        follower._followedUserId = userToFollow.awsUser._userPoolUserId
        follower._followedUserDisplayName = userToFollow.awsUser._displayName
        follower._followedUserUsername = userToFollow.awsUser._username
        follower._followerUserId = currentUser.awsUser._userPoolUserId
        follower._followerDisplayName = currentUser.awsUser._displayName
        follower._followerUsername = currentUser.awsUser._username
        
        AWSDynamoDBObjectMapper.default().save(follower) { (error) in
            if let error = error {
                debugPrint("Error when following User: \(error.localizedDescription)")
                completion(false, CustomError(error: error, title: "", desc: "Unable to follow user"))
            }
            else {
                self.appendFollowerToFollowedUsers(user: currentUser, awsFollower: follower)
                completion(true, nil)
            }
        }
    }
    
    
    func followFollower(
        followerToFollow: Follower,
        currentUser: User,
        completion: @escaping SuccessErrorCompletion) {
        
        let follower: AWSFollower = AWSFollower()
        follower._id = UUID().uuidString
        follower._createDate = Date().toISO8601String
        follower._followedUserId = followerToFollow.awsFollower._followerUserId
        follower._followedUserDisplayName = followerToFollow.awsFollower._followerDisplayName
        follower._followedUserUsername = followerToFollow.awsFollower._followerUsername
        follower._followerUserId = currentUser.awsUser._userPoolUserId
        follower._followerDisplayName = currentUser.awsUser._displayName
        follower._followerUsername = currentUser.awsUser._username
        
        AWSDynamoDBObjectMapper.default().save(follower) { (error) in
            if let error = error {
                debugPrint("Error when following User: \(error.localizedDescription)")
                completion(false, CustomError(error: error, title: "", desc: "Unable to follow user"))
            }
            else {
                self.appendFollowerToFollowedUsers(user: currentUser, awsFollower: follower)
                completion(true, nil)
            }
        }
    }
    
    
    
    func unfollowUser(
        followedUser: Follower,
        currentUser: User,
        completion: @escaping SuccessErrorCompletion) {
        AWSDynamoDBObjectMapper.default().remove(followedUser.awsFollower) { (error) in
            if let error = error {
                debugPrint("Error when unfollowing User: \(error.localizedDescription)")
                completion(false, CustomError(error: error, title: "", desc: "Unable to unfollow user"))
            }
            else {
                self.removeFollowerFromFollowedUsers(user: currentUser, awsFollower: followedUser.awsFollower)
                completion(true, nil)
            }
        }
    }
    
    
    
    func getFollowers(
        for awsUser: AWSUser,
        completion: @escaping (_ followers: [Follower], _ error: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#followedUserId = :userPoolUserId"
        scanExpression.expressionAttributeNames = [
            "#followedUserId": "followedUserId"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":userPoolUserId": awsUser._userPoolUserId!
        ]
        
        var followers = [Follower]()
        
        AWSDynamoDBObjectMapper.default().scan(
            AWSFollower.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(followers, CustomError(error: error, title: "", desc: "Unable to get followers"))
            }
            else if let result = paginatedOutput {
                for awsFollower in result.items {
                    followers.append(Follower(awsFollower: awsFollower as! AWSFollower, followerType: .follower))
                }
                completion(followers, nil)
            }
            else {
                completion(followers, nil)
            }
        }
    }
    
    
    
    func getFollowedUsers(
        for awsUser: AWSUser,
        completion: @escaping (_ followers: [Follower], _ error: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#followerUserId = :userPoolUserId"
        scanExpression.expressionAttributeNames = [
            "#followerUserId": "followerUserId"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":userPoolUserId": awsUser._userPoolUserId!
        ]
        
        var followers = [Follower]()
        
        AWSDynamoDBObjectMapper.default().scan(
            AWSFollower.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(followers, CustomError(error: error, title: "", desc: "Unable to get followed users"))
            }
            else if let result = paginatedOutput {
                for awsFollower in result.items {
                    followers.append(Follower(awsFollower: awsFollower as! AWSFollower, followerType: .following))
                }
                completion(followers, nil)
            }
            else {
                completion(followers, nil)
            }
        }
    }
    
    func removeFollowerFromFollowedUsers(user: User, awsFollower: AWSFollower) {
        if let index = user.followedUsers.index(where: {$0.awsFollower._followedUserId == awsFollower._followedUserId }) {
            user.followedUsers.remove(at: index)
        }
    }
    
    private func appendFollowerToFollowedUsers(user: User, awsFollower: AWSFollower) {
        if !user.followedUsers.contains(where: {$0.awsFollower._followedUserId == awsFollower._followedUserId }) {
            user.followedUsers.append(Follower(awsFollower: awsFollower, followerType: .following))
        }
    }
}
