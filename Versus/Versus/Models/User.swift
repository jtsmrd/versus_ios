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
    var competitions = [Competition]()
    
    init(awsUser: AWSUser) {
        self.awsUser = awsUser
    }
    
    func getProfileImage(completion: @escaping (UIImage?) -> Void) {
        
        guard awsUser._profileImageUpdateDate != nil else {
            completion(nil)
            return
        }
        
        guard profileImage == nil else {
            completion(profileImage)
            return
        }
        S3BucketService.instance.downloadImage(
            imageName: awsUser._userPoolUserId!,
            bucketType: .profileImage
        ) { (image, error) in
            if let error = error {
                debugPrint("Could not download profile image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.profileImage = image
                completion(image)
            }
        }
    }
    
    func getProfileBackgroundImage(completion: @escaping (UIImage?) -> Void) {
        
        guard awsUser._profileBackgroundImageUpdateDate != nil else {
            completion(nil)
            return
        }
        
        guard profileBackgroundImage == nil else {
            completion(profileBackgroundImage)
            return
        }
        S3BucketService.instance.downloadImage(
            imageName: awsUser._userPoolUserId!,
            bucketType: .profileBackgroundImage
        ) { (image, error) in
            if let error = error {
                debugPrint("Could not download profile background image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.profileBackgroundImage = image
                completion(image)
            }
        }
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
    
    func getCompetitions(completion: @escaping SuccessErrorCompletion) {
        
        CompetitionService.instance.getCompetitionsFor(userPoolUserId: awsUser._userPoolUserId!) { (competitions, error) in
            if let error = error {
                completion(false, error)
            }
            else {
                self.competitions = competitions
                completion(true, nil)
            }
        }
    }
}
