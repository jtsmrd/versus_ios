//
//  Follower.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class Follower {
    
    var awsFollower: AWSFollower!
    var profileImage: UIImage?
    
    init(awsFollower: AWSFollower) {
        self.awsFollower = awsFollower
    }
}
