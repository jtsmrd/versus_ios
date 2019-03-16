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
    
    private init() { }
}

extension CurrentAccount {
    
    
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
    }
    
    
    static func setUser(user: User) {
        _user = user
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
    static var lastSignedInUserId: String {
        get {
            return userDefaults.string(forKey: "lastSignedInUserId") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "lastSignedInUserId")
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
}
