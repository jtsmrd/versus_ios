//
//  Vote.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class Vote {
    
    private let voteService = VoteService.instance
    
    private let awsVote: AWSVote
    
    private let competitionIdUserId: String
    private(set) var competitionEntryId: String {
        get {
            return awsVote._competitionEntryId ?? ""
        }
        set {
            awsVote._competitionEntryId = newValue
        }
    }
    
    
    /**
     
     */
    init(awsVote: AWSVote) {
        self.awsVote = awsVote
        self.competitionIdUserId = awsVote._competitionIdUserId ?? ""
    }
    
    
    /**
 
     */
    func changeVote(
        competitionEntryId: String,
        completion: @escaping (_ vote: Vote?, _ customError: CustomError?) -> Void
    ) {
        self.competitionEntryId = competitionEntryId
        voteService.updateVote(
            awsVote: awsVote,
            completion: completion
        )
    }
}
