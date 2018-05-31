//
//  CompetitionService.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB
import AVKit

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
    
    
    // Download the competition image corresponding to the competitionUser and bucketType
    func getCompetitionImage(
        for competitionUser: CompetitionUser,
        competition: Competition,
        bucketType: S3BucketType,
        completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        
        var imageName = ""
        
        // Get the appropriate image name for each combination of user/ bucket type
        switch competitionUser {
        case .user1:
            
            switch bucketType {
            case .profileImage, .profileImageSmall, .profileBackgroundImage:
                imageName = competition.awsCompetition._user1userPoolUserId!
            case .competitionImage:
                imageName = competition.awsCompetition._user1ImageId!
            case .competitionImageSmall:
                imageName = competition.awsCompetition._user1ImageSmallId!
            case .competitionVideoPreviewImage:
                imageName = competition.awsCompetition._user1VideoPreviewImageId!
            case .competitionVideoPreviewImageSmall:
                imageName = competition.awsCompetition._user1VideoPreviewImageSmallId!
            case .competitionVideo:
                break
            }
            
        case .user2:
            
            switch bucketType {
            case .profileImage, .profileImageSmall, .profileBackgroundImage:
                imageName = competition.awsCompetition._user2userPoolUserId!
            case .competitionImage:
                imageName = competition.awsCompetition._user2ImageId!
            case .competitionImageSmall:
                imageName = competition.awsCompetition._user2ImageSmallId!
            case .competitionVideoPreviewImage:
                imageName = competition.awsCompetition._user2VideoPreviewImageId!
            case .competitionVideoPreviewImageSmall:
                imageName = competition.awsCompetition._user2VideoPreviewImageSmallId!
            case .competitionVideo:
                break
            }
        }
        
        S3BucketService.instance.downloadImage(
            imageName: imageName,
            bucketType: bucketType
        ) { (image, error) in
            completion(image, error)
        }
    }
    
    func getCompetitionVideo(
        for competitionUser: CompetitionUser,
        competition: Competition,
        completion: @escaping (_ videoAsset: AVURLAsset?, _ error: Error?) -> Void) {
        
        var videoName = ""
        
        switch competitionUser {
        case .user1:
            videoName = competition.awsCompetition._user1VideoId!
        case .user2:
            videoName = competition.awsCompetition._user2VideoId!
        }
        
        S3BucketService.instance.downloadVideo(
            videoName: videoName,
            bucketType: .competitionVideo
        ) { (asset, error) in
            completion(asset, error)
        }
    }
}
