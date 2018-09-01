//
//  CompetitionEntry.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionEntry {
    
    private let awsCompetitionEntry: AWSCompetitionEntry
    
    var awaitingMatch: Bool
    var caption: String
    var categoryTypeId: Int
    var competitionEntryId: String
    var competitionTypeId: Int
    var createDate: Date
    var displayName: String
    var isFeatured: Bool
    var mediaId: String
    var rankId: Int
    var userId: String
    var username: String
    
    init(awsCompetitionEntry: AWSCompetitionEntry) {
        self.awsCompetitionEntry = awsCompetitionEntry
        
        self.awaitingMatch = awsCompetitionEntry._awaitingMatch?.boolValue ?? false
        self.caption = awsCompetitionEntry._caption ?? ""
        self.categoryTypeId = awsCompetitionEntry._categoryTypeId?.intValue ?? 0
        self.competitionEntryId = awsCompetitionEntry._competitionEntryId ?? ""
        self.competitionTypeId = awsCompetitionEntry._competitionTypeId?.intValue ?? 0
        self.createDate = awsCompetitionEntry._createDate?.toISO8601Date ?? Date()
        self.displayName = awsCompetitionEntry._displayName ?? ""
        self.isFeatured = awsCompetitionEntry._isFeatured?.boolValue ?? false
        self.mediaId = awsCompetitionEntry._mediaId ?? ""
        self.rankId = awsCompetitionEntry._rankId?.intValue ?? 1
        self.userId = awsCompetitionEntry._userId ?? ""
        self.username = awsCompetitionEntry._username ?? ""
    }
    
    
    // Get competition media
}
