//
//  CurrentAccount.swift
//  Versus
//
//  Created by JT Smrdel on 3/2/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import Foundation
let userDefaults = UserDefaults.standard

class CurrentAccount {
    
    static private var _user: User?
    static private var _token: String?
    static private var _followedUserIds = [Int]()
    
    private static let notificationCenter = NotificationCenter.default
    
    private init() { }
}

extension CurrentAccount {
    
    
    static var followedUserIds: [Int] {
        get {
            return _followedUserIds
        }
    }
    
    
    static var user: User {
        get {
            return _user ?? User()
        }
    }
    
    
    static var token: String {
        get {
            return _token ?? ""
        }
    }
    
    
    static func setAccount(account: Account) {
        _user = account.user
        _token = account.token
        lastSignedInUsername = account.user.username
        lastSignedInUserId = account.user.id
        lastAccessToken = account.token
    }
    
    
    static func setUser(user: User) {
        _user = user
    }
    
    
    static func setToken(token: String) {
        _token = token
        lastAccessToken = token
    }
    
    
    static func setFollowedUserIds(ids: [Int]) {
        _followedUserIds = ids
    }
    
    
    static func addFollowedUserId(id: Int) {
        _followedUserIds.append(id)
        postFollowersUpdated()
    }
    
    
    static func removeFollowedUserId(id: Int) {
        if let index = followedUserIds.firstIndex(of: id) {
            _followedUserIds.remove(at: index)
            postFollowersUpdated()
        }
    }
    
    
    static func getFollowStatusFor(userId: Int) -> FollowStatus {
        
        return followedUserIds.contains(userId) ? .following : .notFollowing
    }
    
    
    /// Determine if the giver User id is identical to the current logged in user.
    ///
    /// - Parameter userId: User id
    /// - Returns: Bool
    static func userIsMe(userId: Int) -> Bool {
        return user.id == userId
    }
    
    
    /// Stores the userPoolUserId of the active user after signing up or signing in.
    /// Used for instance where a user deletes the app, but doesn't sign out.
    static var lastSignedInUserId: Int {
        get {
            return userDefaults.integer(forKey: "lastSignedInUserId")
        }
        set {
            userDefaults.set(newValue, forKey: "lastSignedInUserId")
        }
    }
    
    
    static var lastAccessToken: String {
        get {
            return userDefaults.string(forKey: "lastAccessToken") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "lastAccessToken")
        }
    }
    
    
    /// Used to control initially displaying the tutorial. The tutorialDisplayed key won't exist on first startup
    /// so it returns false by default. After user enters the app the value is set to true.
    static var tutorialDisplayed: Bool {
        get {
            return userDefaults.bool(forKey: "tutorialDisplayed")
        }
        set(value) {
            userDefaults.set(value, forKey: "tutorialDisplayed")
        }
    }
    
    
    /// Used to populate the email/ username textfield when a user signs out and back in again.
    static private(set) var lastSignedInUsername: String? {
        get {
            return userDefaults.string(forKey: "lastSignedInUsername")
        }
        set(value) {
            userDefaults.set(value, forKey: "lastSignedInUsername")
        }
    }
    
    
    /// Stores the device token for remote notifications after the user registers for notifications.
    static var remoteNotificationDeviceToken: String? {
        get {
            return userDefaults.string(forKey: "remoteNotificationDeviceToken")
        }
        set(value) {
            userDefaults.set(value, forKey: "remoteNotificationDeviceToken")
        }
    }
    
    
    /// Stores whether or not the user allowed push notifation authouization.
    static var userGrantedAccessForNotifications: Bool {
        get {
            return userDefaults.bool(forKey: "userGrantedAccessForNotifications")
        }
        set(value) {
            userDefaults.set(value, forKey: "userGrantedAccessForNotifications")
        }
    }
    
    
    private static func postFollowersUpdated() {
        notificationCenter.post(
            name: NSNotification.Name.OnFollowersUpdated,
            object: nil
        )
    }
}
