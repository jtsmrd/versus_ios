//
//  CommentService.swift
//  Versus
//
//  Created by JT Smrdel on 7/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//


class CommentService {
    
    static let instance = CommentService()
    
    private init() { }
    
    
    /**
     
     */
    func postComment(
        competitionEntryId: String,
        commentText: String,
        userId: String,
        username: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
//        let comment = Comment(
//            competitionEntryId: competitionEntryId,
//            message: commentText,
//            userId: userId,
//            username: username
//        )
        
//        dynamoDB.save(comment) { (error) in
//
//            if let error = error {
//                completion(CustomError(error: error, message: "Unable to post comment"))
//                return
//            }
//            completion(nil)
//        }
    }
    
    
    /**
     
     */
//    func getComments(
//        for competitionEntryId: String,
//        completion: @escaping (_ comments: [Comment], _ error: CustomError?) -> Void
//    ) {
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.keyConditionExpression = "#competitionEntryId = :competitionEntryId"
//        queryExpression.expressionAttributeNames = [
//            "#competitionEntryId": "competitionEntryId"
//        ]
//        queryExpression.expressionAttributeValues = [
//            ":competitionEntryId": competitionEntryId
//        ]
//        queryExpression.scanIndexForward = false
//
//        var comments = [Comment]()
//
//        dynamoDB.query(
//            Comment.self,
//            expression: queryExpression
//        ) { (paginatedOutput, error) in
//            if let error = error {
//                completion(comments, CustomError(error: error, message: "Unable to load comments"))
//                return
//            }
//            if let commentsResult = paginatedOutput?.items as? [Comment] {
//                for item in commentsResult {
//                    comments.append(item)
//                }
//            }
//            completion(comments, nil)
//        }
//    }
}
