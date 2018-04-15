//
//  CurrentUser.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class CurrentUser {
    
    static var user: User!
    static var userPoolUserId: String {
        get {
            return AWSCognitoIdentityUserPool.default().currentUser()?.username ?? ""
        }
    }
    
    private init() { }
    
    static func isFollowing(user: User) -> Bool {
        return self.user.followedUsers.contains(
            where: {$0.awsFollower._followedUserId == user.awsUser._userPoolUserId}
        )
    }
    
    static func followStatus(for user: User) -> FollowStatus {
        if self.user.followedUsers.contains(where: {$0.awsFollower._followedUserId == user.awsUser._userPoolUserId}) {
            return .following
        }
        return .notFollowing
    }
    
    static func isFollowing(follower: Follower) -> Bool {
        switch follower.followerType! {
        case .follower:
            return user.followedUsers.contains(
                where: {$0.awsFollower._followedUserId == follower.awsFollower._followerUserId}
            )
        case .following:
            return user.followedUsers.contains(
                where: {$0.awsFollower._followedUserId == follower.awsFollower._followedUserId}
            )
        }
    }
    
    static func followStatus(for follower: Follower) -> FollowStatus {
        switch follower.followerType! {
        case .follower:
            if user.followedUsers.contains(where: {$0.awsFollower._followedUserId == follower.awsFollower._followerUserId}) {
                return .following
            }
            return .notFollowing
        case .following:
            if user.followedUsers.contains(where: {$0.awsFollower._followedUserId == follower.awsFollower._followedUserId}) {
                return .following
            }
            return .notFollowing
        }
    }
    
    static func getFollower(for user: User) -> Follower? {
        return self.user.followedUsers.first(where: {$0.awsFollower._followedUserId == user.awsUser._userPoolUserId})
    }
    
    static func getFollower(for followedUser: Follower) -> Follower? {
        switch followedUser.followerType! {
        case .follower:
            return self.user.followedUsers.first(where: {$0.awsFollower._followedUserId == followedUser.awsFollower._followerUserId})
        case .following:
            return self.user.followedUsers.first(where: {$0.awsFollower._followedUserId == followedUser.awsFollower._followedUserId})
        }
    }
}
