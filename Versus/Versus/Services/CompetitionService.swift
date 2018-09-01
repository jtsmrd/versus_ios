//
//  CompetitionService.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB
import AWSCognitoIdentityProvider
import AVKit
import AWSLambda

class CompetitionService {
    
    static let instance = CompetitionService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    private let lambda = AWSLambdaInvoker.default()
    private let s3BucketService = S3BucketService.instance
    
    private init() { }
    
    
    //TODO: Sort results by newest Competition
    /**
     
     */
    func getFollowedUserCompetitions(
        followedUserIds: [String],
        completion: @escaping (_ competitions: [Competition], _ customError: CustomError?) -> Void
    ) {
        var competitions = [Competition]()
        let jsonObject: [String: Any] = ["followedUserIds": followedUserIds]
        lambda.invokeFunction("GetFollowedUserCompetitions", jsonObject: jsonObject) { (result, error) in
            if let error = error {
                completion(competitions, CustomError(error: error, message: "Unable to get followed user Competitions"))
                return
            }
            if let result = result as? NSDictionary,
                let competitionsDict = result["Items"] as? NSArray {
                for competitionDict in competitionsDict {
                    let competition = CompetitionParser().fromDictionary(competitionDictionary: competitionDict as! NSDictionary)
                    competitions.append(competition)
                }
            }
            completion(competitions, nil)
        }
    }
    
    
    /**
     
     */
    func getFeaturedCompetitions(
        categoryId: Int?,
        completion: @escaping (_ competitions: [Competition], _ error: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        if let categoryId = categoryId {
            queryExpression.keyConditionExpression = "#isFeaturedCategoryTypeId = :isFeaturedCatType AND startDate < :currentDate"
            queryExpression.expressionAttributeNames = [
                "#isFeaturedCategoryTypeId": "isFeaturedCategoryTypeId"
            ]
            queryExpression.expressionAttributeValues = [
                ":isFeaturedCatType": String(format: "1|%d", categoryId),
                ":currentDate": Date().toISO8601String
            ]
            queryExpression.indexName = "isFeaturedCategoryTypeId-startDate-index"
        }
        else {
            queryExpression.keyConditionExpression = "#isFeatured = :isFeatured AND startDate < :currentDate"
            queryExpression.expressionAttributeNames = [
                "#isFeatured": "isFeatured"
            ]
            queryExpression.expressionAttributeValues = [
                ":isFeatured": 1,
                ":currentDate": Date().toISO8601String
            ]
            queryExpression.indexName = "isFeatured-startDate-index"
        }
        queryExpression.scanIndexForward = false
        
        var competitions = [Competition]()
        dynamoDB.query(
            AWSCompetition.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(competitions, CustomError(error: error, message: "Unable to get featured competitions"))
                return
            }
            if let result = paginatedOutput {
                for competition in result.items {
                    competitions.append(Competition(awsCompetition: competition as! AWSCompetition))
                }
            }
            completion(competitions, nil)
        }
    }
    
    
    /**
     
     */
    func getCompetitionsFor(
        userId: String,
        completion: @escaping (_ competitions: [Competition], _ error: CustomError?) -> Void
    ) {
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#firstEntryUserId = :userId OR #secondEntryUserId = :userId"
        scanExpression.expressionAttributeNames = [
            "#firstEntryUserId": "firstEntryUserId",
            "#secondEntryUserId": "secondEntryUserId"
        ]
        scanExpression.expressionAttributeValues = [
            ":userId": userId
        ]
        
        var competitions = [Competition]()
        dynamoDB.scan(
            AWSCompetition.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(competitions, CustomError(error: error, message: "Unable to get competitions for user"))
                return
            }
            if let result = paginatedOutput {
                for competition in result.items {
                    competitions.append(Competition(awsCompetition: competition as! AWSCompetition))
                }
            }
            completion(competitions, nil)
        }
    }
    
    
    /**
     
     */
    func getCompetition(
        competitionId: String,
        completion: @escaping (_ competition: Competition?, _ error: CustomError?) -> Void
    ) {
        dynamoDB.load(
            AWSCompetition.self,
            hashKey: competitionId,
            rangeKey: nil
        ) { (awsCompetition, error) in
            if let error = error {
                completion(nil, CustomError(error: error, message: "Unable to get competition"))
            }
            else if let awsCompetition = awsCompetition as? AWSCompetition {
                completion(Competition(awsCompetition: awsCompetition), nil)
            }
            else {
                completion(nil, nil)
            }
        }
    }
}
