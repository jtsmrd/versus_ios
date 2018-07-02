//
//  LeaderService.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class LeaderService {
    
    static let instance = LeaderService()
    
    private init() { }
    
    
    /*
     Get the leaders for the given leaderboard
     */
    func getLeaders(
        for leaderboard: Leaderboard,
        completion: @escaping (_ leaders: [Leader], _ customError: CustomError?) -> Void) {
        
        var resultClass: AnyClass!
        let queryExpression = AWSDynamoDBQueryExpression()
        
        switch leaderboard.leaderboardType {
        case .weekly:
            
            resultClass = AWSWeeklyLeader.self
            
            let lastTwoDigitsOfYear = Calendar.current.component(.year, from: Date()) % 100
            let weekOfYear = Calendar.current.component(.weekOfYear, from: Date())
            let weekYear = Int(String(format: "%i%i", weekOfYear, lastTwoDigitsOfYear))!    //2718
            
            queryExpression.keyConditionExpression = "#weekYear = :weekYear"
            queryExpression.expressionAttributeNames = [
                "#weekYear": "weekYear"
            ]
            queryExpression.expressionAttributeValues = [
                ":weekYear": weekYear
            ]
            queryExpression.indexName = "weekYearIndex"
            
        case .monthly:
            
            resultClass = AWSMonthlyLeader.self
            
            let lastTwoDigitsOfYear = Calendar.current.component(.year, from: Date()) % 100
            let monthOfYear = Calendar.current.component(.month, from: Date())
            let yearMonth = Int(String(format: "%i%02i", lastTwoDigitsOfYear, monthOfYear))!    //1807
            
            queryExpression.keyConditionExpression = "#yearMonth = :yearMonth"
            queryExpression.expressionAttributeNames = [
                "#yearMonth": "yearMonth"
            ]
            queryExpression.expressionAttributeValues = [
                ":yearMonth": yearMonth
            ]
            queryExpression.indexName = "yearMonthIndex"
            
        case .allTime:
            return
        }
        
        queryExpression.scanIndexForward = false
        queryExpression.limit = leaderboard.numberOfResults.toNSNumber
        
        var leaders = [Leader]()
        
        AWSDynamoDBObjectMapper.default().query(
            resultClass,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(leaders, CustomError(error: error, title: "", desc: "Unable to load leaders"))
            }
            else if let result = paginatedOutput {
                for awsLeader in result.items {
                    leaders.append(Leader(awsLeader: awsLeader))
                }
                completion(leaders, nil)
            }
        }
    }
    
    
    
    /*
     Get the leaders for the given leaderboard
     */
    func getTopLeader(
        for leaderboard: Leaderboard,
        completion: @escaping (_ leader: Leader?, _ customError: CustomError?) -> Void) {
        
        var resultClass: AnyClass!
        let queryExpression = AWSDynamoDBQueryExpression()
        
        switch leaderboard.leaderboardType {
        case .weekly:
            
            resultClass = AWSWeeklyLeader.self
            
            let lastTwoDigitsOfYear = Calendar.current.component(.year, from: Date()) % 100
            let weekOfYear = Calendar.current.component(.weekOfYear, from: Date())
            let weekYear = Int(String(format: "%i%i", weekOfYear, lastTwoDigitsOfYear))!    //2718
            
            queryExpression.keyConditionExpression = "#weekYear = :weekYear"
            queryExpression.expressionAttributeNames = [
                "#weekYear": "weekYear"
            ]
            queryExpression.expressionAttributeValues = [
                ":weekYear": weekYear
            ]
            queryExpression.indexName = "weekYearIndex"
            
        case .monthly:
            
            resultClass = AWSMonthlyLeader.self
            
            let lastTwoDigitsOfYear = Calendar.current.component(.year, from: Date()) % 100
            let monthOfYear = Calendar.current.component(.month, from: Date())
            let yearMonth = Int(String(format: "%i%02i", lastTwoDigitsOfYear, monthOfYear))!    //1807
            
            queryExpression.keyConditionExpression = "#yearMonth = :yearMonth"
            queryExpression.expressionAttributeNames = [
                "#yearMonth": "yearMonth"
            ]
            queryExpression.expressionAttributeValues = [
                ":yearMonth": yearMonth
            ]
            queryExpression.indexName = "yearMonthIndex"
            
        case .allTime:
            return
        }
        
        queryExpression.scanIndexForward = false
        queryExpression.limit = 1.toNSNumber
        
        AWSDynamoDBObjectMapper.default().query(
            resultClass,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to load top leader"))
            }
            else if let awsLeader = paginatedOutput?.items.first {
                completion(Leader(awsLeader: awsLeader), nil)
            }
        }
    }
}
