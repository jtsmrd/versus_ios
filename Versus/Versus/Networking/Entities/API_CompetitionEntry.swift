//
//  API_CompetitionEntry.swift
//  Versus
//
//  Created by JT Smrdel on 12/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

struct API_CompetitionEntry: Codable {
    
    var competitionEntryId: Int
    var isMatched: Int
    var caption: String?
    var categoryTypeId: Int
    var competitionTypeId: Int
    var createDate: String
    var matchDate: String?
    var displayName: String
    var isFeatured: Int
    var mediaId: String
    var rankId: Int
    var userId: String
    var username: String
    
    init(
        caption: String?,
        categoryTypeId: Int,
        competitionTypeId: Int,
        mediaId: String
    ) {
        self.competitionEntryId = 0
        self.isMatched = 0
        self.caption = caption
        self.categoryTypeId = categoryTypeId
        self.competitionTypeId = competitionTypeId
        self.createDate = ""
        self.displayName = CurrentUser.displayName
        self.isFeatured = Int(exactly: NSNumber(booleanLiteral: CurrentUser.isFeatured)) ?? 0
        self.mediaId = mediaId
        self.rankId = CurrentUser.rankId
        self.userId = CurrentUser.userId
        self.username = CurrentUser.username
    }
}
