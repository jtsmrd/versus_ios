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
    
    static private let followedUserService = FollowedUserService.instance
    static private let userService = UserService.instance
    static private let notificationManager = NotificationManager.instance
    
    static private var awsUser: AWSUser!
    static private var user: User!
    
    static var bio: String {
        get {
            return awsUser._bio ?? ""
        }
        set {
            awsUser._bio = newValue
        }
    }
    
    static var displayName: String {
        get {
            return awsUser._displayName ?? ""
        }
        set {
            awsUser._displayName = newValue
        }
    }
    
    static var searchDisplayName: String {
        get {
            return awsUser._searchDisplayName ?? ""
        }
        set {
            awsUser._searchDisplayName = newValue
        }
    }
    
    static var searchUsername: String {
        get {
            return awsUser._searchUsername ?? ""
        }
        set {
            awsUser._searchUsername = newValue
        }
    }
    
    static var followedUserCount: Int {
        return awsUser._followedUserCount?.intValue ?? 0
    }
    
    static var followerCount: Int {
        return awsUser._followerCount?.intValue ?? 0
    }
    
    static var isFeatured: Bool {
        return awsUser._isFeatured?.boolValue ?? false
    }
    
    static var rankId: Int {
        return awsUser._rankId?.intValue ?? 1
    }
    
    static var totalTimesVoted: Int {
        get {
            return awsUser._totalTimesVoted?.intValue ?? 0
        }
        set {
            awsUser._totalTimesVoted = newValue.toNSNumber
        }
    }
    
    static var totalWins: Int {
        return awsUser._totalWins?.intValue ?? 0
    }
    
    static var userId: String {
        return AWSCognitoIdentityUserPool.default().currentUser()?.username ?? ""
    }
    
    static var username: String {
        get {
            return awsUser._username ?? ""
        }
        set {
            awsUser._username = newValue
        }
    }
    
    static var directMessageConversationIds: [String: String] {
        return awsUser._directMessageConversationIds ?? [:]
    }
    
    static var profileImage: UIImage? {
        get {
            return CurrentUser.user.profileImage
        }
        set {
            CurrentUser.user.profileImage = newValue
        }
    }
    static var profileBackgroundImage: UIImage? {
        get {
            return CurrentUser.user.profileBackgroundImage
        }
        set {
            CurrentUser.user.profileBackgroundImage = newValue
        }
    }
    static var rank: Rank {
        return CurrentUser.user.rank
    }
    static var followers: [Follower] {
        get {
            return CurrentUser.user.followers
        }
        set {
            CurrentUser.user.followers = newValue
        }
    }
    static var followedUsers: [FollowedUser] {
        get {
            return CurrentUser.user.followedUsers
        }
        set {
            CurrentUser.user.followedUsers = newValue
        }
    }
    static var competitions: [Competition] {
        return CurrentUser.user.competitions
    }
    
    private init() { }
    
    
    /**
     
     */
    static func setAWSUser(awsUser: AWSUser) {
        CurrentUser.awsUser = awsUser
        CurrentUser.user = User(awsUser: awsUser)
        CurrentUser.loadUserData()
        CurrentUser.lastSignedInUserId = awsUser._userId ?? "userId nil"
    }
    
    
    /**
        Stores the userPoolUserId of the active user after signing up or signing in.
        Used for instance where a user deletes the app, but doesn't sign out.
    */
    static var lastSignedInUserId: String {
        get {
            return userDefaults.string(forKey: "lastSignedInUserId") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "lastSignedInUserId")
        }
    }
    
    
    /**
        Used to control initially displaying the tutorial. The tutorialDisplayed key won't exist on first startup
        so it returns false by default. After user enters the app the value is set to true.
    */
    static var tutorialDisplayed: Bool {
        get {
            return userDefaults.bool(forKey: "tutorialDisplayed")
        }
        set(value) {
            userDefaults.set(value, forKey: "tutorialDisplayed")
        }
    }
    
    
    /**
        Used to populate the email/ username textfield when a user signs out and back in again.
    */
    static var lastSignedInUsername: String? {
        get {
            return userDefaults.string(forKey: "lastSignedInUsername")
        }
        set(value) {
            userDefaults.set(value, forKey: "lastSignedInUsername")
        }
    }
    
    
    /**
        Stores the device token for remote notifications after the user registers for notifications.
     */
    static var remoteNotificationDeviceToken: String? {
        get {
            return userDefaults.string(forKey: "remoteNotificationDeviceToken")
        }
        set(value) {
            userDefaults.set(value, forKey: "remoteNotificationDeviceToken")
        }
    }
    
    
    /**
        Stores whether or not the user allowed push notifation authouization.
     */
    static var userGrantedAccessForNotifications: Bool {
        get {
            return userDefaults.bool(forKey: "userGrantedAccessForNotifications")
        }
        set(value) {
            userDefaults.set(value, forKey: "userGrantedAccessForNotifications")
        }
    }
    
    
    /**
        Stores the AWS SNS Endpoint ARN for remote notifications after the user registers for notifications.
     */
    static var userAWSSNSEndpointARN: String? {
        get {
            return userDefaults.string(forKey: "userAWSSNSEndpointARN")
        }
        set(value) {
            userDefaults.set(value, forKey: "userAWSSNSEndpointARN")
        }
    }
    
    
    /**
     
     */
    static func setSignInCredentials(signInCredentials: SignInCredentials) {
        UserDefaults.standard.set(signInCredentials.username, forKey: "signupUsername")
        UserDefaults.standard.set(signInCredentials.password, forKey: "signupPassword")
    }
    
    
    /**
     
     */
    static func getSignInCredentials() -> SignInCredentials {
        let username = UserDefaults.standard.string(forKey: "signupUsername") ?? ""
        let password = UserDefaults.standard.string(forKey: "signupPassword") ?? ""
        return SignInCredentials(username: username, password: password)
    }
    
    
    /**
     
     */
    static func clearSignupCredentials() {
        UserDefaults.standard.set(nil, forKey: "signupUsername")
        UserDefaults.standard.set(nil, forKey: "signupPassword")
    }
    
    
    /**
     
     */
    static func getUser() -> User {
        return CurrentUser.user
    }
    
    
    /**
     
     */
    static func getProfileImage(
        completion: @escaping (_ image: UIImage?, _ error: CustomError?) -> Void
    ) {
        CurrentUser.user.getProfileImage(completion: completion)
    }
    
    
    /**
     
     */
    static func getProfileBackgroundImage(
        completion: @escaping (_ image: UIImage?, _ error: CustomError?) -> Void
    ) {
        CurrentUser.user.getProfileBackgroundImage(completion: completion)
    }
    
    
    /**
     
     */
    static func getFollowers(
        completion: @escaping (_ followers: [Follower], _ customError: CustomError?) -> Void
    ) {
        CurrentUser.user.getFollowers(completion: completion)
    }
    
    
    /**
     
     */
    static func getFollowedUser(userId: String) -> FollowedUser? {
        return followedUsers.first(where: { $0.followedUserUserId == userId })
    }
    
    
    /**
     
     */
    static func getFollowedUsers(
        completion: @escaping (_ followedUsers: [FollowedUser], _ customError: CustomError?) -> Void
    ) {
        CurrentUser.user.getFollowedUsers(completion: completion)
    }
    
    
    /**
 
     */
    static func follow(
        user: User,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        follow(
            displayName: user.displayName,
            followedUserUserId: user.userId,
            followerDisplayName: CurrentUser.displayName,
            followerUsername: CurrentUser.username,
            searchDisplayName: user.displayName.lowercased(),
            searchUsername: user.username.lowercased(),
            username: user.username,
            userId: CurrentUser.userId
        ) { (followedUser, customError) in
            
            if let followedUser = followedUser {
                self.followedUsers.append(followedUser)
            }
            completion(customError)
        }
    }
    
    
    /**
     
     */
    static func follow(
        follower: Follower,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        follow(
            displayName: follower.displayName,
            followedUserUserId: follower.followerUserId,
            followerDisplayName: CurrentUser.displayName,
            followerUsername: CurrentUser.username,
            searchDisplayName: follower.displayName.lowercased(),
            searchUsername: follower.username.lowercased(),
            username: follower.username,
            userId: CurrentUser.userId
        ) { (followedUser, customError) in
            
            if let followedUser = followedUser {
                self.followedUsers.append(followedUser)
            }
        }
    }
    
    
    /**
     
     */
    private static func follow(
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
        followedUserService.follow(
            displayName: displayName,
            followedUserUserId: followedUserUserId,
            followerDisplayName: followerDisplayName,
            followerUsername: followerUsername,
            searchDisplayName: searchDisplayName,
            searchUsername: searchUsername,
            username: username,
            userId: userId,
            completion: completion
        )
    }
    
    
    /**
     
     */
    static func unfollow(
        followedUser: FollowedUser,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        followedUserService.unfollow(
            followedUser: followedUser
        ) { (customError) in
            if let customError = customError {
                completion(customError)
            }
            self.removeFollowedUser(followedUser: followedUser)
            completion(nil)
        }
    }
    
    
    /**
     
     */
    static func unfollow(
        user: User,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        guard let followedUser = getFollowedUser(userId: user.userId) else {
            completion(CustomError(error: nil, message: "Failed to unfollow user"))
            return
        }
        unfollow(followedUser: followedUser, completion: completion)
    }
    
    
    /**
     
     */
    private static func removeFollowedUser(followedUser: FollowedUser) {
        if let index = followedUsers.index(where: { $0.followedUserUserId == followedUser.followedUserUserId }) {
            followedUsers.remove(at: index)
        }
    }
    
    
    /**
     
     */
    static func getCompetitions(
        completion: @escaping (_ competitions: [Competition], _ customError: CustomError?) -> Void
    ) {
        CurrentUser.user.getCompetitions(completion: completion)
    }
    
    
    /**
     
     */
    static func userIsMe(userId: String) -> Bool {
        return userId == CurrentUser.userId
    }
    
    
    /**
     
     */
    static func getFollowedUserStatusFor(userId: String) -> FollowStatus {
        if CurrentUser.followedUsers.contains(where: { $0.followedUserUserId == userId }) {
            return .following
        }
        return .notFollowing
    }
    
    
    /**
     
     */
    static func getFollowerStatusFor(userId: String) -> FollowStatus {
        if CurrentUser.followers.contains(where: { $0.followerUserId == userId }) {
            return .following
        }
        return .notFollowing
    }
    
    
    /**
     
     */
    static func getFollowerFor(userId: String) -> Follower? {
        return CurrentUser.followers.first(where: { $0.followerUserId == userId })
    }
    
    
    /**
     TODO: Is this still needed? User vote count is incremented with Vote trigger funtion.
     */
    static func incrementVoteCount() {
        awsUser._totalTimesVoted = (CurrentUser.totalTimesVoted + 1).toNSNumber
    }
    
    
    /**
     
     */
    static func update(
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        userService.updateUser(
            user: awsUser,
            completion: completion
        )
    }
    
    
    /**
     
     */
    static func updateProfile(
        profileImage: UIImage?,
        backgroundImage: UIImage?,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        userService.updateProfile(
            awsUser: awsUser,
            profileImage: profileImage,
            backgroundImage: backgroundImage,
            completion: completion
        )
    }
    
    
    /**
     
     */
    static func loadUserData() {
        getNotifications()
        
        getFollowers { (followers, customError) in
            if let customError = customError {
                debugPrint(customError)
            }
        }
        
        getFollowedUsers { (followedUsers, customError) in
            if let customError = customError {
                debugPrint(customError)
            }
        }
        
        getCompetitions { (competitions, customError) in
            if let customError = customError {
                debugPrint(customError)
            }
        }
        
        getProfileImage { (image, error) in
            
        }
        
        getProfileBackgroundImage { (image, error) in
            
        }
    }
    
    
    /**
     
     */
    static func getNotifications() {
        notificationManager.getCurrentUserNotifications { (notifications, customError) in
            if let customError = customError {
                debugPrint("Error getting notifications: \(customError.error!.localizedDescription)")
            }
        }
    }
}
