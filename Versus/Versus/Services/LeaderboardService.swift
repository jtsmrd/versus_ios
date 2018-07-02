//
//  LeaderboardService.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class LeaderboardService {
    
    static let instance = LeaderboardService()
    
    private init() { }
    
    
    func getLeaderboards(completion: @escaping (_ leaderboards: [Leaderboard], _ customError: CustomError?) -> Void) {
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#isActive = :isActive"
        queryExpression.expressionAttributeNames = [
            "#isActive": "isActive"
        ]
        queryExpression.expressionAttributeValues = [
            ":isActive": 1
        ]
        queryExpression.indexName = "isActiveIndex"
        
        var leaderboards = [Leaderboard]()
        
        AWSDynamoDBObjectMapper.default().query(AWSLeaderboard.self, expression: queryExpression) { (paginatedOutput, error) in
            if let error = error {
                completion(leaderboards, CustomError(error: error, title: "", desc: "Unable to load leaderboards"))
            }
            else if let result = paginatedOutput {
                if let awsLeaderboards = result.items as? [AWSLeaderboard] {
                    for awsLeaderboard in awsLeaderboards {
                        leaderboards.append(Leaderboard(awsLeaderboard: awsLeaderboard))
                    }
                }
                completion(leaderboards, nil)
            }
        }
    }
}
