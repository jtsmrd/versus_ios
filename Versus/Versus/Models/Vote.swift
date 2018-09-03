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
    
    private let competitionId: String
    private let competitionIdUserId: String
    private(set) var competitionEntryId: String {
        get {
            return awsVote._competitionEntryId ?? ""
        }
        set {
            awsVote._competitionEntryId = newValue
        }
    }
    private var competitor: String {
        get {
            return awsVote._competitor ?? ""
        }
        set {
            awsVote._competitor = newValue
        }
    }
    var competitorType: CompetitorType? {
        return CompetitorType(rawValue: competitor)
    }
    
    
    /**
     
     */
    init(awsVote: AWSVote) {
        self.awsVote = awsVote
        self.competitionId = awsVote._competitionId ?? ""
        self.competitionIdUserId = awsVote._competitionIdUserId ?? ""
    }
}
