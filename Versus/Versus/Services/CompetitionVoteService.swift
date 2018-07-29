//
//  CompetitionVoteService.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB
import AWSLambda

class CompetitionVoteService {
    
    static let instance = CompetitionVoteService()
    
    private init() { }
    
    
    func voteForCompetition(
        competitionId: String,
        votedForCompetitionEntryId: String,
        completion: @escaping (_ competitionVote: CompetitionVote?, _ customError: CustomError?) -> Void) {
        
        let competitionVote: AWSCompetitionVote = AWSCompetitionVote()
        competitionVote._competitionIdUserPoolUserId = String(format: "%@%@", competitionId, CurrentUser.userPoolUserId)
        competitionVote._competitionEntryId = votedForCompetitionEntryId
        
        AWSDynamoDBObjectMapper.default().save(competitionVote) { (error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to vote on competition."))
            }
            debugPrint("Successfully voted")
            completion(CompetitionVote(awsCompetitionVote: competitionVote), nil)
        }
    }
    
    
    func getVoteForCompetition(competitionId: String, completion: @escaping (_ competitionVote: CompetitionVote?) -> Void) {
        
        let hashKey = String(format: "%@%@", competitionId, CurrentUser.userPoolUserId)
        
        AWSDynamoDBObjectMapper.default().load(
            AWSCompetitionVote.self,
            hashKey: hashKey,
            rangeKey: nil
        ) { (awsCompetitionVote, error) in
            if let error = error {
                debugPrint("Error getting vote for competition: \(error.localizedDescription)")
                completion(nil)
            }
            else if let awsCompetitionVote = awsCompetitionVote as? AWSCompetitionVote {
                completion(CompetitionVote(awsCompetitionVote: awsCompetitionVote))
            }
            else {
                completion(nil)
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
    
    
    func getVoteCountFor(
        _ competitionEntryId: String,
        completion: @escaping (_ voteCount: Int?, _ error: CustomError?) -> Void
    ) {
        
        let jsonObject: [String: Any] = ["competitionEntryId": competitionEntryId]
        AWSLambdaInvoker.default().invokeFunction("versus-1_0-GetCompetitionEntryVoteCount", jsonObject: jsonObject) { (result, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to get comment count"))
            }
            else if let count = result as? Int {
                completion(count, nil)
            }
        }
    }
}
