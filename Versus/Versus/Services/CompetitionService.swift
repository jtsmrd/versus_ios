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
    
    
    func getFeaturedCompetitionsWith(
        categoryId id: Int,
        completion: @escaping (_ competitions: [Competition], _ error: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#isFeatured = :isFeatured AND #categoryId = :categoryId"
        scanExpression.expressionAttributeNames = [
            "#isFeatured": "isFeatured",
            "#categoryId": "categoryId"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":isFeatured": 1,
            ":categoryId": id
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
    
    
    func getCompetition(
        with id: String,
        completion: @escaping (_ competition: Competition?, _ error: CustomError?) -> Void) {
        
        AWSDynamoDBObjectMapper.default().load(
            AWSCompetition.self,
            hashKey: id,
            rangeKey: nil
        ) { (awsCompetition, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to get competition"))
            }
            else if let awsCompetition = awsCompetition as? AWSCompetition {
                completion(Competition(awsCompetition: awsCompetition), nil)
            }
            else {
                completion(nil, nil)
            }
        }
    }
    
    
    func getCompetitionImage(
        for user: User,
        competition: Competition,
        completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        
        var imageName = ""
        var bucketType: S3BucketType!
        
        if user.awsUser._userPoolUserId == competition.awsCompetition._user1userPoolUserId {
            
            switch competition.competitionType {
            case .image:
                imageName = competition.awsCompetition._user1ImageSmallId!
                bucketType = .competitionImageSmall
            case .video:
                imageName = competition.awsCompetition._user1VideoPreviewImageSmallId!
                bucketType = .competitionVideoPreviewImageSmall
            }
        }
        else {
            switch competition.competitionType {
            case .image:
                imageName = competition.awsCompetition._user2ImageSmallId!
                bucketType = .competitionImageSmall
            case .video:
                imageName = competition.awsCompetition._user2VideoPreviewImageSmallId!
                bucketType = .competitionVideoPreviewImageSmall
            }
        }
        
        S3BucketService.instance.downloadImage(
            imageName: imageName,
            bucketType: bucketType
        ) { (image, error) in
            completion(image, error)
        }
    }
}
