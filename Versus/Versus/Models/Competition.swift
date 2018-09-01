//
//  Competition.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum CompetitionType: Int {
    case image = 1
    case video = 2
}

class Competition {
    
    private let categoryCollection = CategoryCollection.instance
    
    private let awsCompetition: AWSCompetition
    
    var categoryTypeId: Int
    var competitionId: String
    var expireDate: Date
    var competitionTypeId: Int
    var firstCompetitor: Competitor
    var isActive: Bool
    var isFeatured: Bool
    var secondCompetitor: Competitor
    var startDate: Date
    var timeExtended: Bool
    var winnerUserId: String
    
    
    var category: Category {
        return categoryCollection.getCategory(categoryType: CategoryType(rawValue: categoryTypeId)!)!
    }
    
    var competitionType: CompetitionType {
        return CompetitionType(rawValue: competitionTypeId)!
    }
    
    var isExpired: Bool {
        return expireDate < Date()
    }
    
    var secondsUntilExpire: Int? {
        return Date().seconds(until: expireDate)
    }
    
    
    init(awsCompetition: AWSCompetition) {
        self.awsCompetition = awsCompetition
        
        self.categoryTypeId = awsCompetition._categoryTypeId?.intValue ?? 1
        self.competitionId = awsCompetition._competitionId ?? ""
        self.expireDate = awsCompetition._expireDate?.toISO8601Date ?? Date()
        self.isFeatured = awsCompetition._isFeatured?.boolValue ?? false
        self.competitionTypeId = awsCompetition._competitionTypeId?.intValue ?? 1
        self.firstCompetitor = Competitor(
            competitorType: .first,
            caption: awsCompetition._firstEntryCaption ?? "",
            commentCount: awsCompetition._firstEntryCommentCount?.intValue ?? 0,
            competitionId: awsCompetition._competitionId ?? "",
            competitionEntryId: awsCompetition._firstEntryCompetitionEntryId ?? "",
            competitionTypeId: awsCompetition._competitionTypeId?.intValue ?? 1,
            mediaId: awsCompetition._firstEntryMediaId ?? "",
            userId: awsCompetition._firstEntryUserId ?? "",
            username: awsCompetition._firstEntryUsername ?? "",
            userRankId: awsCompetition._firstEntryUserRankId?.intValue ?? 1,
            voteCount: awsCompetition._firstEntryVoteCount?.intValue ?? 0
        )
        self.isActive = awsCompetition._competitionIsActive?.boolValue ?? false
        self.secondCompetitor = Competitor(
            competitorType: .second,
            caption: awsCompetition._secondEntryCaption ?? "",
            commentCount: awsCompetition._secondEntryCommentCount?.intValue ?? 0,
            competitionId: awsCompetition._competitionId ?? "",
            competitionEntryId: awsCompetition._secondEntryCompetitionEntryId ?? "",
            competitionTypeId: awsCompetition._competitionTypeId?.intValue ?? 1,
            mediaId: awsCompetition._secondEntryMediaId ?? "",
            userId: awsCompetition._secondEntryUserId ?? "",
            username: awsCompetition._secondEntryUsername ?? "",
            userRankId: awsCompetition._secondEntryUserRankId?.intValue ?? 1,
            voteCount: awsCompetition._secondEntryVoteCount?.intValue ?? 0
        )
        self.startDate = awsCompetition._startDate?.toISO8601Date ?? Date()
        self.timeExtended = awsCompetition._timeExtended?.boolValue ?? false
        self.winnerUserId = awsCompetition._winnerUserId ?? ""
    }
}
