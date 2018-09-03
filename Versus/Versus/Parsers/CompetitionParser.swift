//
//  CompetitionParser.swift
//  Versus
//
//  Created by JT Smrdel on 6/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

struct CompetitionParser {
    
    func fromDictionary(competitionDictionary: NSDictionary) -> Competition {
        
        let awsCompetition: AWSCompetition = AWSCompetition()
        awsCompetition._competitionId = competitionDictionary["competitionId"] as? String
        awsCompetition._competitionIsActive = competitionDictionary["competitionIsActive"] as? NSNumber
        awsCompetition._expireDate = competitionDictionary["expireDate"] as? String
        awsCompetition._firstCompetitorCommentCount = competitionDictionary["firstCompetitorCommentCount"] as? NSNumber
        awsCompetition._firstCompetitorCaption = competitionDictionary["firstCompetitorCaption"] as? String
        awsCompetition._firstCompetitorEntryId = competitionDictionary["firstCompetitorEntryId"] as? String
        awsCompetition._firstCompetitorMediaId = competitionDictionary["firstCompetitorMediaId"] as? String
        awsCompetition._firstCompetitorUsername = competitionDictionary["firstCompetitorUsername"] as? String
        awsCompetition._firstCompetitorUserRankId = competitionDictionary["firstCompetitorUserRankId"] as? NSNumber
        awsCompetition._firstCompetitorUserId = competitionDictionary["firstCompetitorUserId"] as? String
        awsCompetition._firstCompetitorVoteCount = competitionDictionary["firstCompetitorVoteCount"] as? NSNumber
        awsCompetition._isFeaturedCategoryTypeId = competitionDictionary["isFeaturedCategoryTypeId"] as? String
        awsCompetition._secondCompetitorCommentCount = competitionDictionary["secondCompetitorCommentCount"] as? NSNumber
        awsCompetition._secondCompetitorCaption = competitionDictionary["secondCompetitorCaption"] as? String
        awsCompetition._secondCompetitorEntryId = competitionDictionary["secondCompetitorEntryId"] as? String
        awsCompetition._secondCompetitorMediaId = competitionDictionary["secondCompetitorMediaId"] as? String
        awsCompetition._secondCompetitorUsername = competitionDictionary["secondCompetitorUsername"] as? String
        awsCompetition._secondCompetitorUserRankId = competitionDictionary["secondCompetitorUserRankId"] as? NSNumber
        awsCompetition._secondCompetitorUserId = competitionDictionary["secondCompetitorUserId"] as? String
        awsCompetition._secondCompetitorVoteCount = competitionDictionary["secondCompetitorVoteCount"] as? NSNumber
        awsCompetition._startDate = competitionDictionary["startDate"] as? String
        awsCompetition._timeExtended = competitionDictionary["timeExtended"] as? NSNumber
        awsCompetition._winnerUserId = competitionDictionary["winnerUserId"] as? String
        
        return Competition(awsCompetition: awsCompetition)
    }
}
