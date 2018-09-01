//
//  CommentService.swift
//  Versus
//
//  Created by JT Smrdel on 7/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB
import AWSLambda

class CommentService {
    
    static let instance = CommentService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    private let lambda = AWSLambdaInvoker.default()
    
    private init() { }
    
    
    /**
     
     */
    func postComment(
        competitionEntryId: String,
        commentText: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        let awsComment: AWSComment = AWSComment()
        awsComment._competitionEntryId = competitionEntryId
        awsComment._createDate = Date().toISO8601String
        awsComment._commentId = UUID().uuidString
        awsComment._likeCount = 0.toNSNumber
        awsComment._message = commentText
        awsComment._userId = CurrentUser.userId
        awsComment._username = CurrentUser.username
        
        dynamoDB.save(
            awsComment
        ) { (error) in
            if let error = error {
                completion(CustomError(error: error, message: "Unable to post comment"))
                return
            }
            completion(nil)
        }
    }
    
    
    /**
     
     */
    func getComments(
        for competitionEntryId: String,
        completion: @escaping (_ comments: [Comment], _ error: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#competitionEntryId = :competitionEntryId"
        queryExpression.expressionAttributeNames = [
            "#competitionEntryId": "competitionEntryId"
        ]
        queryExpression.expressionAttributeValues = [
            ":competitionEntryId": competitionEntryId
        ]
        queryExpression.scanIndexForward = false
        
        var comments = [Comment]()
        dynamoDB.query(
            AWSComment.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(comments, CustomError(error: error, message: "Unable to load comments"))
                return
            }
            if let awsComments = paginatedOutput?.items as? [AWSComment] {
                for awsComment in awsComments {
                    comments.append(Comment(awsComment: awsComment))
                }
            }
            completion(comments, nil)
        }
    }
}
