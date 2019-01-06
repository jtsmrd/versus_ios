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
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    
    private init() { }
    
    
    /**
 
     */
    func getLeaderboards(
        completion: @escaping (_ leaderboards: [Leaderboard], _ customError: CustomError?) -> Void
    ) {
//        let scanExpression = AWSDynamoDBScanExpression()
//        scanExpression.filterExpression = "#isActive = :val"
//        scanExpression.expressionAttributeNames = [
//            "#isActive": "isActive"
//        ]
//        scanExpression.expressionAttributeValues = [
//            ":val": 1
//        ]
//        var leaderboards = [Leaderboard]()
//        dynamoDB.scan(
//            AWSLeaderboard.self,
//            expression: scanExpression
//        ) { (paginatedOutput, error) in
//            if let error = error {
//                completion(leaderboards, CustomError(error: error, message: "Unable to load leaderboards"))
//                return
//            }
//            if let awsLeaderboards = paginatedOutput?.items as? [AWSLeaderboard] {
//                for awsLeaderboard in awsLeaderboards {
//                    leaderboards.append(Leaderboard(awsLeaderboard: awsLeaderboard))
//                }
//            }
//            completion(leaderboards, nil)
//        }
    }
}
