//
//  User.swift
//  Versus
//
//  Created by JT Smrdel on 4/12/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class User {
    
    private let s3BucketService = S3BucketService.instance
    private let competitionService = CompetitionService.instance
    private let followerService = FollowerService.instance
    private let followedUserService = FollowedUserService.instance
    
    var bio: String
    var displayName: String
    var followedUserCount: Int
    var followerCount: Int
    var isFeatured: Bool
    var rankId: Int
    var totalTimesVoted: Int
    var totalWins: Int
    var userId: String
    var username: String
    
    var profileImage: UIImage?
    var profileImageDownloadState: ImageDownloadState = .new
    var profileBackgroundImage: UIImage?
    var followers = [Follower]()
    var followedUsers = [FollowedUser]()
    var competitions = [Competition]()
    var rank: Rank {
        return RankCollection.instance.rankFor(rankId: rankId)
    }
    
    
    /**
     
     */
    init(awsUser: AWSUser) {
        self.bio = awsUser._bio ?? ""
        self.displayName = awsUser._displayName ?? ""
        self.followedUserCount = awsUser._followedUserCount?.intValue ?? 0
        self.followerCount = awsUser._followerCount?.intValue ?? 0
        self.isFeatured = awsUser._isFeatured?.boolValue ?? false
        self.rankId = awsUser._rankId?.intValue ?? 1
        self.totalTimesVoted = awsUser._totalTimesVoted?.intValue ?? 0
        self.totalWins = awsUser._totalWins?.intValue ?? 0
        self.userId = awsUser._userId ?? ""
        self.username = awsUser._username ?? ""
    }
    
    
    /**
     
     */
    func getProfileImage(
        completion: @escaping (_ profileImage: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard profileImage == nil else {
            completion(profileImage, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: userId,
            imageType: .small
        ) { (image, customError) in
            self.profileImage = image
            completion(image, customError)
        }
    }
    
    
    /**
     
     */
    func getProfileBackgroundImage(
        completion: @escaping (_ profileBackgroundImage: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard profileBackgroundImage == nil else {
            completion(profileBackgroundImage, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: userId,
            imageType: .background
        ) { (image, customError) in
            self.profileBackgroundImage = image
            completion(image, customError)
        }
    }
    
    
    // TODO: Handle pagination
    /**
     
     */
    func getFollowers(
        completion: @escaping (_ followers: [Follower], _ customError: CustomError?) -> Void
    ) {
        followerService.getFollowers(
            userId: userId
        ) { (followers, customError) in
            self.followers = followers
            completion(followers, customError)
        }
    }
    
    
    // TODO: Handle pagination
    /**
     
     */
    func getFollowedUsers(
        completion: @escaping (_ followedUsers: [FollowedUser], _ customError: CustomError?) -> Void
    ) {
        followedUserService.getFollowedUsers(
            userId: userId
        ) { (followedUsers, customError) in
            self.followedUsers = followedUsers
            completion(followedUsers, customError)
        }
    }
    
    
    /**
 
     */
    func getCompetitions(
        completion: @escaping (_ competitions: [Competition], _ customError: CustomError?) -> Void
    ) {
        competitionService.getCompetitionsFor(
            userId: userId
        ) { (competitions, error) in
            // Only add new competitions
            for competition in competitions {
                if !self.competitions.contains(where: { $0.competitionId == competition.competitionId }) {
                    self.competitions.append(competition)
                }
            }
            completion(self.competitions, error)
        }
    }
}
