//
//  CompetitionVoteService.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class CompetitionVoteService {
    
    static let instance = CompetitionVoteService()
    
    private init() { }
    
    
    func voteForCompetition(
        competitionId: String,
        votedForUserPoolUserId: String,
        completion: @escaping SuccessCompletion) {
        
        let competitionVote: AWSCompetitionVote = AWSCompetitionVote()
        competitionVote._competitionId = competitionId
        competitionVote._createDate = Date().iso8601
        competitionVote._id = UUID().uuidString
        competitionVote._userPoolUserId = CurrentUser.userPoolUserId
        competitionVote._votedForUserPoolUserId = votedForUserPoolUserId
        
        AWSDynamoDBObjectMapper.default().save(competitionVote) { (error) in
            if let error = error {
                debugPrint("Error when saving Competition Vote: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("Successfully voted")
            completion(true)
        }
    }
    
    func getVoteForCompetition(competitionId: String, completion: @escaping (_ votedForUserPoolUserId: String?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#competitionId = :competitionId AND #userPoolUserId = :userPoolUserId"
        scanExpression.expressionAttributeNames = [
            "#competitionId": "competitionId",
            "#userPoolUserId": "userPoolUserId"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":competitionId": competitionId,
            ":userPoolUserId": CurrentUser.userPoolUserId
        ]
        
        AWSDynamoDBObjectMapper.default().scan(CompetitionVote.self, expression: scanExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error getting vote for competition: \(error.localizedDescription)")
                completion(nil)
            }
            else if let result = paginatedOutput {
                if let competitionVote = result.items.first as? AWSCompetitionVote {
                    completion(competitionVote._votedForUserPoolUserId)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
}
