//
//  CompetitionParser.swift
//  Versus
//
//  Created by JT Smrdel on 6/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

struct CompetitionParser {
    
    func fromDictionary(competitionDictionary: NSDictionary) -> Competition? {
        
        guard let categoryId = competitionDictionary["categoryId"] as? Int else { return nil }
        guard let competitionTypeId = competitionDictionary["competitionTypeId"] as? Int else { return nil }
        guard let expireDate = competitionDictionary["expireDate"] as? String else { return nil }
        guard let id = competitionDictionary["id"] as? String else { return nil }
        guard let isFeatured = competitionDictionary["isFeatured"] as? Int else { return nil }
        guard let startDate = competitionDictionary["startDate"] as? String else { return nil }
        guard let status = competitionDictionary["status"] as? String else { return nil }
        
        guard let user1CompetitionEntryId = competitionDictionary["user1CompetitionEntryId"] as? String else { return nil }
        guard let user1ImageId = competitionDictionary["user1ImageId"] as? String else { return nil }
        guard let user1ImageSmallId = competitionDictionary["user1ImageSmallId"] as? String else { return nil }
        guard let user1RankId = competitionDictionary["user1RankId"] as? Int else { return nil }
        guard let user1Username = competitionDictionary["user1Username"] as? String else { return nil }
        guard let user1VideoId = competitionDictionary["user1VideoId"] as? String else { return nil }
        guard let user1VideoPreviewImageId = competitionDictionary["user1VideoPreviewImageId"] as? String else { return nil }
        guard let user1VideoPreviewImageSmallId = competitionDictionary["user1VideoPreviewImageSmallId"] as? String else { return nil }
        guard let user1userPoolUserId = competitionDictionary["user1userPoolUserId"] as? String else { return nil }
        
        guard let user2CompetitionEntryId = competitionDictionary["user2CompetitionEntryId"] as? String else { return nil }
        guard let user2ImageId = competitionDictionary["user2ImageId"] as? String else { return nil }
        guard let user2ImageSmallId = competitionDictionary["user2ImageSmallId"] as? String else { return nil }
        guard let user2RankId = competitionDictionary["user2RankId"] as? Int else { return nil }
        guard let user2Username = competitionDictionary["user2Username"] as? String else { return nil }
        guard let user2VideoId = competitionDictionary["user2VideoId"] as? String else { return nil }
        guard let user2VideoPreviewImageId = competitionDictionary["user2VideoPreviewImageId"] as? String else { return nil }
        guard let user2VideoPreviewImageSmallId = competitionDictionary["user2VideoPreviewImageSmallId"] as? String else { return nil }
        guard let user2userPoolUserId = competitionDictionary["user2userPoolUserId"] as? String else { return nil }
        
        let awsCompetition: AWSCompetition = AWSCompetition()
        awsCompetition._categoryId = categoryId.toNSNumber
        awsCompetition._competitionTypeId = competitionTypeId.toNSNumber
        awsCompetition._expireDate = expireDate
        awsCompetition._id = id
        awsCompetition._isFeatured = isFeatured.toNSNumber
        awsCompetition._startDate = startDate
        awsCompetition._status = status
        
        awsCompetition._user1CompetitionEntryId = user1CompetitionEntryId
        awsCompetition._user1ImageId = user1ImageId
        awsCompetition._user1ImageSmallId = user1ImageSmallId
        awsCompetition._user1RankId = user1RankId.toNSNumber
        awsCompetition._user1Username = user1Username
        awsCompetition._user1VideoId = user1VideoId
        awsCompetition._user1VideoPreviewImageId = user1VideoPreviewImageId
        awsCompetition._user1VideoPreviewImageSmallId = user1VideoPreviewImageSmallId
        awsCompetition._user1userPoolUserId = user1userPoolUserId
        
        awsCompetition._user2CompetitionEntryId = user2CompetitionEntryId
        awsCompetition._user2ImageId = user2ImageId
        awsCompetition._user2ImageSmallId = user2ImageSmallId
        awsCompetition._user2RankId = user2RankId.toNSNumber
        awsCompetition._user2Username = user2Username
        awsCompetition._user2VideoId = user2VideoId
        awsCompetition._user2VideoPreviewImageId = user2VideoPreviewImageId
        awsCompetition._user2VideoPreviewImageSmallId = user2VideoPreviewImageSmallId
        awsCompetition._user2userPoolUserId = user2userPoolUserId
        
        return Competition(awsCompetition: awsCompetition)
    }
}
