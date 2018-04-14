//
//  FollowerService.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSUserPoolsSignIn
import AWSDynamoDB

class FollowerService {
    
    static let instance = FollowerService()
    
    private init() { }
    
    
    
    func followUser(userToFollow: User, completion: @escaping SuccessErrorCompletion) {
        guard let userPoolUserId = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
            debugPrint("AWS user username nil")
            completion(false, nil)
            return
        }
        
        let follower: AWSFollower = AWSFollower()
        follower._id = UUID.init().uuidString
        follower._createDate = String(Date().timeIntervalSince1970)
        follower._followedUserId = userToFollow.awsUser._userPoolUserId
        follower._followerUserId = userPoolUserId
        follower._displayName = CurrentUser.user.awsUser._displayName
        follower._username = CurrentUser.user.awsUser._username
        
        AWSDynamoDBObjectMapper.default().save(follower) { (error) in
            if let error = error {
                debugPrint("Error when following User: \(error.localizedDescription)")
                completion(false, CustomError(error: error, title: "", desc: "Unable to follow user"))
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    
    
    func unfollowUser() {
        
    }
    
    
    
    func getFollowers() {
        
    }
    
    
    
    func getFollowedUsers() {
        
    }
}
