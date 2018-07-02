//
//  Leader.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

enum LeaderType: Int {
    case weekly = 1
    case monthly = 2
    case allTime = 3
}

class Leader {
    
    var awsLeader: AWSDynamoDBObjectModel!
    var leaderType: LeaderType!
    var username: String!
    var totalWins: Int!
    var totalVotes: Int!
    var userPoolUserId: String!
    
    init(awsLeader: AWSDynamoDBObjectModel) {
        self.awsLeader = awsLeader
        
        if let weeklyLeader = awsLeader as? AWSWeeklyLeader {
            leaderType = .weekly
            username = String(format: "@%@", weeklyLeader._username!)
            totalWins = weeklyLeader._totalWinsDuringWeek!.intValue
            totalVotes = weeklyLeader._totalVotesDuringWeek!.intValue
            userPoolUserId = weeklyLeader._userPoolUserId!
        }
        else if let monthlyLeader = awsLeader as? AWSMonthlyLeader {
            leaderType = .monthly
            username = String(format: "@%@", monthlyLeader._username!)
            totalWins = monthlyLeader._totalWinsDuringMonth!.intValue
            totalVotes = monthlyLeader._totalVotesDuringMonth!.intValue
            userPoolUserId = monthlyLeader._userPoolUserId!
        }
        else if let allTimeLeader = awsLeader as? AWSAllTimeLeader {
            leaderType = .allTime
            username = String(format: "@%@", allTimeLeader._username!)
            totalWins = allTimeLeader._totalWins!.intValue
            totalVotes = allTimeLeader._totalVotes!.intValue
            userPoolUserId = allTimeLeader._userPoolUserId!
        }
    }
}
