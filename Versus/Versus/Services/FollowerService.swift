//
//  FollowerService.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class FollowerService {
    
    static let instance = FollowerService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    
    private init() { }
    
    func getFollowers(
        userId: String,
        completion: @escaping (_ followers: [Follower], _ error: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId"
        ]
        queryExpression.expressionAttributeValues = [
            ":userId": userId
        ]
        
        var followers = [Follower]()
        dynamoDB.query(
            Follower.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(followers, CustomError(error: error, message: "Unable to get followers"))
                return
            }
            if let result = paginatedOutput,
                let followerResults = result.items as? [Follower] {
                for item in followerResults {
                    followers.append(item)
                }
            }
            completion(followers, nil)
        }
    }
}
