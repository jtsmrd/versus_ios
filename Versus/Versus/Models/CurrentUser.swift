//
//  CurrentUser.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
let userDefaults = UserDefaults.standard

class CurrentUser {
    
    static var user: User! {
        didSet {
            loadUserData()
            localUserPoolUserId = userPoolUserId
        }
    }
    static var userPoolUserId: String {
        get {
            return AWSCognitoIdentityUserPool.default().currentUser()?.username ?? ""
        }
    }
    
    /*
     Stores the userPoolUserId of the active user after signing up or signing in.
     Used for instance where a user deletes the app, but doesn't sign out.
    */
    static var localUserPoolUserId: String {
        get {
            return userDefaults.string(forKey: "localUserPoolUserId") ?? ""
        }
        set(value) {
            userDefaults.set(value, forKey: "localUserPoolUserId")
        }
    }
    
    private init() { }
    
    static func setSignInCredentials(signInCredentials: SignInCredentials) {
        UserDefaults.standard.set(signInCredentials.username, forKey: "signupUsername")
        UserDefaults.standard.set(signInCredentials.password, forKey: "signupPassword")
    }
    
    static func getSignInCredentials() -> SignInCredentials {
        let username = UserDefaults.standard.string(forKey: "signupUsername") ?? ""
        let password = UserDefaults.standard.string(forKey: "signupPassword") ?? ""
        return SignInCredentials(username: username, password: password)
    }
    
    static func clearSignupCredentials() {
        UserDefaults.standard.set(nil, forKey: "signupUsername")
        UserDefaults.standard.set(nil, forKey: "signupPassword")
    }
    
    
    static func followerIsMe(follower: Follower) -> Bool {
        switch follower.followerType! {
        case .follower:
            return follower.awsFollower._followerUserId == userPoolUserId
        case .following:
            return follower.awsFollower._followedUserId == userPoolUserId
        }
    }
    
    
    static func userIsMe(user: User) -> Bool {
        return user.awsUser._userPoolUserId == userPoolUserId
    }
    
    static func userIsMe(awsUser: AWSUser) -> Bool {
        return awsUser._userPoolUserId == userPoolUserId
    }
    
    
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
    
    static func followStatus(for userPoolUserId: String) -> FollowStatus {
        if self.user.followedUsers.contains(where: {$0.awsFollower._followedUserId == userPoolUserId}) {
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
    
    static func loadUserData() {
        getNotifications()
        
        user.getFollowers { (success, customError) in
            if !success {
                debugPrint("Failed to load followers")
            }
        }
        
        user.getFollowedUsers { (followedUsers, customError) in
            if let customError = customError {
                debugPrint(customError)
            }
        }
        
        user.getCompetitions { (success, customError) in
            if !success {
                debugPrint("Failed to load user competitions")
            }
        }
        
        user.getProfileBackgroundImage { (image) in
            
        }
        
        user.getProfileImage { (image) in
            
        }
    }
    
    static func getNotifications() {
        NotificationManager.instance.getCurrentUserNotifications { (notifications, customError) in
            if let customError = customError {
                debugPrint("Error getting notifications: \(customError.error!.localizedDescription)")
            }
        }
    }
}
