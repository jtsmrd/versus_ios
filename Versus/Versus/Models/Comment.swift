//
//  Comment.swift
//  Versus
//
//  Created by JT Smrdel on 7/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class Comment {
    
    private(set) var awsComment: AWSComment!
    
    init(awsComment: AWSComment) {
        self.awsComment = awsComment
    }
}
