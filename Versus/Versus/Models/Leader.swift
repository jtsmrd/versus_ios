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
    
    var awsLeader: AWSDynamoDBObjectModel
    var leaderType: LeaderType = .allTime
    var username: String = ""
    var wins: Int = 0
    var votes: Int = 0
    var userId: String = ""
    
    init(awsLeader: AWSDynamoDBObjectModel) {
        self.awsLeader = awsLeader
        
        if let weeklyLeader = awsLeader as? AWSWeeklyLeader {
            self.leaderType = .weekly
            self.userId = weeklyLeader._userId ?? ""
            self.username = weeklyLeader._username ?? ""
            self.wins = weeklyLeader._wins?.intValue ?? 0
            self.votes = weeklyLeader._votes?.intValue ?? 0
        }
        else if let monthlyLeader = awsLeader as? AWSMonthlyLeader {
            self.leaderType = .monthly
            self.userId = monthlyLeader._userId ?? ""
            self.username = monthlyLeader._username ?? ""
            self.wins = monthlyLeader._wins?.intValue ?? 0
            self.votes = monthlyLeader._votes?.intValue ?? 0
        }
        else if let allTimeLeader = awsLeader as? AWSAllTimeLeader {
            self.leaderType = .allTime
            self.userId = allTimeLeader._userId ?? ""
            self.username = allTimeLeader._username ?? ""
            self.wins = allTimeLeader._wins?.intValue ?? 0
            self.votes = allTimeLeader._votes?.intValue ?? 0
        }
    }
}
