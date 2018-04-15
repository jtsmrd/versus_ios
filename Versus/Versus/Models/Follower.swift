//
//  Follower.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum FollowerType {
    case follower
    case following
}

enum FollowStatus {
    case following
    case notFollowing
}

class Follower {
    
    var awsFollower: AWSFollower!
    var followerType: FollowerType!
    var profileImageSmall: UIImage?
    
    init(awsFollower: AWSFollower, followerType: FollowerType) {
        self.awsFollower = awsFollower
        self.followerType = followerType
    }
}
