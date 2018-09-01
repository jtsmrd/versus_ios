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
        awsCompetition._firstEntryCommentCount = competitionDictionary["firstEntryCommentCount"] as? NSNumber
        awsCompetition._firstEntryCaption = competitionDictionary["firstEntryCaption"] as? String
        awsCompetition._firstEntryCompetitionEntryId = competitionDictionary["firstEntryCompetitionEntryId"] as? String
        awsCompetition._firstEntryMediaId = competitionDictionary["firstEntryMediaId"] as? String
        awsCompetition._firstEntryUsername = competitionDictionary["firstEntryUsername"] as? String
        awsCompetition._firstEntryUserRankId = competitionDictionary["firstEntryUserRankId"] as? NSNumber
        awsCompetition._firstEntryUserId = competitionDictionary["firstEntryUserId"] as? String
        awsCompetition._firstEntryVoteCount = competitionDictionary["firstEntryVoteCount"] as? NSNumber
        awsCompetition._isFeaturedCategoryTypeId = competitionDictionary["isFeaturedCategoryTypeId"] as? String
        awsCompetition._secondEntryCommentCount = competitionDictionary["secondEntryCommentCount"] as? NSNumber
        awsCompetition._secondEntryCaption = competitionDictionary["secondEntryCaption"] as? String
        awsCompetition._secondEntryCompetitionEntryId = competitionDictionary["secondEntryCompetitionEntryId"] as? String
        awsCompetition._secondEntryMediaId = competitionDictionary["secondEntryMediaId"] as? String
        awsCompetition._secondEntryUsername = competitionDictionary["secondEntryUsername"] as? String
        awsCompetition._secondEntryUserRankId = competitionDictionary["secondEntryUserRankId"] as? NSNumber
        awsCompetition._secondEntryUserId = competitionDictionary["secondEntryUserId"] as? String
        awsCompetition._secondEntryVoteCount = competitionDictionary["secondEntryVoteCount"] as? NSNumber
        awsCompetition._startDate = competitionDictionary["startDate"] as? String
        awsCompetition._timeExtended = competitionDictionary["timeExtended"] as? NSNumber
        awsCompetition._winnerUserId = competitionDictionary["winnerUserId"] as? String
        
        return Competition(awsCompetition: awsCompetition)
    }
}
