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
        votedForCompetitionEntryId: String,
        completion: @escaping SuccessCompletion) {
        
        let competitionVote: AWSCompetitionVote = AWSCompetitionVote()
        competitionVote._competitionId = competitionId
        competitionVote._createDate = Date().toISO8601String
        competitionVote._id = UUID().uuidString
        competitionVote._userPoolUserId = CurrentUser.userPoolUserId
        competitionVote._votedForCompetitionEntryId = votedForCompetitionEntryId
        
        AWSDynamoDBObjectMapper.default().save(competitionVote) { (error) in
            if let error = error {
                debugPrint("Error when saving Competition Vote: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("Successfully voted")
            completion(true)
        }
    }
    
    
    func getVoteForCompetition(competitionId: String, completion: @escaping (_ competitionVote: CompetitionVote?) -> Void) {
        
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
        
        AWSDynamoDBObjectMapper.default().scan(AWSCompetitionVote.self, expression: scanExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error getting vote for competition: \(error.localizedDescription)")
                completion(nil)
            }
            else if let result = paginatedOutput {
                if let competitionVote = result.items.first as? AWSCompetitionVote {
                    completion(CompetitionVote(awsCompetitionVote: competitionVote))
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    
    func deleteVoteForCompetition(competitionVote: CompetitionVote, completion: @escaping SuccessErrorCompletion) {
        
        AWSDynamoDBObjectMapper.default().remove(competitionVote.awsCompetitionVote) { (error) in
            if let error = error {
                completion(false, CustomError(error: error, title: "", desc: "Unable to change vote, try again"))
            }
            completion(true, nil)
        }
    }
    
    //TODO: Update to only get COUNT instead of returning all records, or create/ call function in API Gateway instead
    /// Returns the vote count for the given competitionEntryId.
    func getVoteCountFor(
        _ competitionEntryId: String,
        completion: @escaping (_ voteCount: Int?, _ error: CustomError?) -> Void
    ) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#votedForCompetitionEntryId = :votedForCompetitionEntryId"
        scanExpression.expressionAttributeNames = [
            "#votedForCompetitionEntryId": "votedForCompetitionEntryId"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":votedForCompetitionEntryId": competitionEntryId
        ]
        
        AWSDynamoDBObjectMapper.default().scan(
            AWSCompetitionVote.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to get competition votes"))
            }
            else if let result = paginatedOutput {
                completion(result.items.count, nil)
            }
        }
    }
}
