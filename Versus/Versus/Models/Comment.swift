//
//  Comment.swift
//  Versus
//
//  Created by JT Smrdel on 7/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class Comment {
    
    private let awsComment: AWSComment
    
    var competitionEntryId: String
    var createDate: Date
    var commentId: String
    var likeCount: Int
    var message: String
    var userId: String
    var username: String
    
    
    init(awsComment: AWSComment) {
        self.awsComment = awsComment
        
        self.competitionEntryId = awsComment._competitionEntryId ?? ""
        self.createDate = awsComment._createDate?.toISO8601Date ?? Date()
        self.commentId = awsComment._commentId ?? ""
        self.likeCount = awsComment._likeCount?.intValue ?? 0
        self.message = awsComment._message ?? ""
        self.userId = awsComment._userId ?? ""
        self.username = awsComment._username ?? ""
    }
}
