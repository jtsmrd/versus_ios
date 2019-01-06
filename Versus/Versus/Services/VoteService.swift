//
//  VoteService.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB
import AWSLambda

class VoteService {
    
    static let instance = VoteService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    private let lambda = AWSLambdaInvoker.default()
    
    private init() { }
    
    
    /**
     
     */
    func voteForCompetition(
        competition: Competition,
        competitionEntryId: String,
        competitorType: CompetitorType,
        isVoteSwitch: Bool,
        completion: @escaping (_ vote: Vote?, _ customError: CustomError?) -> Void
    ) {
//        let awsVote: AWSVote = AWSVote()
//        awsVote._competitionIdUserId = String(format: "%@%@", competition.competitionId, CurrentUser.userId)
//        awsVote._competitionEntryId = competitionEntryId
//        awsVote._competitionId = competition.competitionId
//        awsVote._competitor = competitorType.rawValue
//
//        dynamoDB.save(
//            awsVote
//        ) { (error) in
//            if let error = error {
//                completion(nil, CustomError(error: error, message: "Unable to vote on competition."))
//                return
//            }
//
//            switch competitorType {
//            case .first:
//                competition.firstCompetitor.voteCount += 1
//                if isVoteSwitch {
//                    competition.secondCompetitor.voteCount -= 1
//                }
//            case .second:
//                competition.secondCompetitor.voteCount += 1
//                if isVoteSwitch {
//                    competition.firstCompetitor.voteCount -= 1
//                }
//            }
//            completion(Vote(awsVote: awsVote), nil)
//        }
    }
    
    
    /**
     
     */
    func updateVote(
        vote: Vote,
        competition: Competition,
        completion: @escaping (_ vote: Vote?, _ customError: CustomError?) -> Void
    ) {
//        dynamoDB.save(
//            vote
//        ) { (error) in
//            if let error = error {
//                completion(nil, CustomError(error: error, message: "Unable to change vote"))
//                return
//            }
//
//            if let competitor = awsVote._competitor,
//                let competitorType = CompetitorType(rawValue: competitor) {
//
//                switch competitorType {
//                case .first:
//                    competition.firstCompetitor.voteCount += 1
//                    competition.secondCompetitor.voteCount -= 1
//                case .second:
//                    competition.secondCompetitor.voteCount += 1
//                    competition.firstCompetitor.voteCount -= 1
//                }
//            }
//
//            completion(Vote(awsVote: awsVote), nil)
//        }
    }
    
    
    /**
     
     */
    func getVoteForCompetition(
        competitionId: String,
        completion: @escaping (_ vote: Vote?) -> Void
    ) {
//        let hashKey = String(format: "%@%@", competitionId, CurrentUser.userId)
//        dynamoDB.load(
//            AWSVote.self,
//            hashKey: hashKey,
//            rangeKey: nil
//        ) { (awsVote, error) in
//            if let error = error {
//                debugPrint("Error getting vote for competition: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//            guard let awsVote = awsVote as? AWSVote else {
//                completion(nil)
//                return
//            }
//            completion(Vote(awsVote: awsVote))
//        }
    }
}
