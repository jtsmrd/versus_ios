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
    
    private init() { }
    
    
    func postComment(
        competitionEntryId: String,
        commentText: String,
        completion: @escaping SuccessCompletion
    ) {
        
        let comment: AWSComment = AWSComment()
        comment._competitionEntryId = competitionEntryId
        comment._createDate = Date().toISO8601String
        comment._commentId = UUID().uuidString
        comment._commentText = commentText
        comment._userPoolUserId = CurrentUser.userPoolUserId
        comment._username = CurrentUser.user.awsUser._username
        
        AWSDynamoDBObjectMapper.default().save(comment) { (error) in
            if let error = error {
                debugPrint("Error when posting comment: \(error.localizedDescription)")
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }
    
    
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
        
        AWSDynamoDBObjectMapper.default().query(AWSComment.self, expression: queryExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading comments: \(error.localizedDescription)")
                completion(comments, CustomError(error: error, title: "", desc: "Unable to load comments"))
            }
            else if let result = paginatedOutput {
                if let awsComments = result.items as? [AWSComment] {
                    for awsComment in awsComments {
                        comments.append(Comment(awsComment: awsComment))
                    }
                }
                completion(comments, nil)
            }
        }
    }
    
    func getCommentCountFor(
        competitionEntryId: String,
        completion: @escaping (_ commentCount: Int?, _ customError: CustomError?) -> Void) {
        
        let jsonObject: [String: Any] = ["competitionEntryId": competitionEntryId]
        AWSLambdaInvoker.default().invokeFunction("versus-1_0-GetCompetitionEntryCommentCount", jsonObject: jsonObject) { (result, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to get comment count"))
            }
            else if let count = result as? Int {
                completion(count, nil)
            }
        }
    }
}
