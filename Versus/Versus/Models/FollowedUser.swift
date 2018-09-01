//
//  FollowedUser.swift
//  Versus
//
//  Created by JT Smrdel on 8/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowedUser {
    
    let s3BucketService = S3BucketService.instance
    let followedUserService = FollowedUserService.instance
    
    let awsFollowedUser: AWSFollowedUser
    
    var createDate: Date
    var displayName: String
    var followedUserUserId: String
    var searchDisplayName: String
    var searchUsername: String
    var username: String
    
    var profileImageSmall: UIImage?
    
    
    init(awsFollowedUser: AWSFollowedUser) {
        self.awsFollowedUser = awsFollowedUser
        self.createDate = awsFollowedUser._createDate?.toISO8601Date ?? Date()
        self.displayName = awsFollowedUser._displayName ?? ""
        self.followedUserUserId = awsFollowedUser._followedUserUserId ?? ""
        self.searchDisplayName = awsFollowedUser._searchDisplayName ?? ""
        self.searchUsername = awsFollowedUser._searchUsername ?? ""
        self.username = awsFollowedUser._username ?? ""
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
            mediaId: followedUserUserId,
            imageType: .small,
            completion: completion
        )
    }
}
