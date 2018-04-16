//
//  User.swift
//  Versus
//
//  Created by JT Smrdel on 4/12/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class User {
    
    var awsUser: AWSUser!
    var profileImage: UIImage?
    var profileBackgroundImage: UIImage?
    var rank: Rank {
        get {
            return RankCollection.instance.ranks.first(where: { $0.id == Int(exactly: awsUser._rankId!)! })!
        }
    }
    var followers = [Follower]()
    var followedUsers = [Follower]()
    
    init(awsUser: AWSUser) {
        self.awsUser = awsUser
    }
    
    func getFollowers(completion: @escaping SuccessErrorCompletion) {
        
        FollowerService.instance.getFollowers(for: awsUser) { (followers, error) in
            if let error = error {
                completion(false, error)
            }
            else {
                self.followers = followers
                completion(true, nil)
            }
        }
    }
    
    func getFollowedUsers(completion: @escaping SuccessErrorCompletion) {
        
        FollowerService.instance.getFollowedUsers(for: awsUser) { (followedUsers, error) in
            if let error = error {
                completion(false, error)
            }
            else {
                self.followedUsers = followedUsers
                completion(true, nil)
            }
        }
    }
}
