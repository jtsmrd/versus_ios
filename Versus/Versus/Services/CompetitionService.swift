//
//  CompetitionService.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class CompetitionService {
    
    static let instance = CompetitionService()
    
    private init() { }
    
    
    
    func getFeaturedCompetitions(
        completion: @escaping (_ competitions: [Competition], _ error: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#isFeatured = :isFeatured"
        scanExpression.expressionAttributeNames = [
            "#isFeatured": "isFeatured"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":isFeatured": 1
        ]
        
        var competitions = [Competition]()
        
        AWSDynamoDBObjectMapper.default().scan(
            AWSCompetition.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(competitions, CustomError(error: error, title: "", desc: "Unable to get featured competitions"))
            }
            else if let result = paginatedOutput {
                for competition in result.items {
                    competitions.append(Competition(awsCompetition: competition as! AWSCompetition))
                }
                completion(competitions, nil)
            }
            else {
                completion(competitions, nil)
            }
        }
    }
    
    
    func getCompetitionsFor(
        userPoolUserId userId: String,
        completion: @escaping (_ competitions: [Competition],
        _ error: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#user1userPoolUserId = :userPoolUserId OR #user2userPoolUserId = :userPoolUserId"
        scanExpression.expressionAttributeNames = [
            "#user1userPoolUserId": "user1userPoolUserId",
            "#user2userPoolUserId": "user2userPoolUserId"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":userPoolUserId": userId
        ]
        
        var competitions = [Competition]()
        
        AWSDynamoDBObjectMapper.default().scan(
            AWSCompetition.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(competitions, CustomError(error: error, title: "", desc: "Unable to get competitions for user"))
            }
            else if let result = paginatedOutput {
                for competition in result.items {
                    competitions.append(Competition(awsCompetition: competition as! AWSCompetition))
                }
                completion(competitions, nil)
            }
            else {
                completion(competitions, nil)
            }
        }
    }
}
