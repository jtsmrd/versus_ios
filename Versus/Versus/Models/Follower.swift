//
//  Follower.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum FollowStatus {
    case following
    case notFollowing
}

class Follower {
    
    let s3BucketService = S3BucketService.instance
    
    var createDate: Date
    var displayName: String
    var followerUserId: String
    var searchDisplayName: String
    var searchUsername: String
    var username: String
    
    var profileImageSmall: UIImage?
    
    
    init(awsFollower: AWSFollower) {
        self.createDate = awsFollower._createDate?.toISO8601Date ?? Date()
        self.displayName = awsFollower._displayName ?? ""
        self.followerUserId = awsFollower._followerUserId ?? ""
        self.searchDisplayName = awsFollower._searchDisplayName ?? ""
        self.searchUsername = awsFollower._searchUsername ?? ""
        self.username = awsFollower._username ?? ""
    }
    
    
    /**
 
     */
    func getProfileImage(
        completion: @escaping (_ profileImage: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard profileImageSmall == nil else {
            completion(profileImageSmall, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: followerUserId,
            imageType: .small
        ) { (image, customError) in
            self.profileImageSmall = image
            completion(image, customError)
        }
    }
}
