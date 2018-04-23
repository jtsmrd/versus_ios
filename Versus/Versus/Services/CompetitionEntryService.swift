//
//  CompetitionEntryService.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class CompetitionEntryService {
    
    static let instance = CompetitionEntryService()
    
    private init() { }
    
    
    func createCompetitionEntry(
        categoryType: CategoryType,
        competitionType: CompetitionType,
        caption: String?,
        videoPreviewImageId: String?,
        videoId: String?,
        imageId: String?,
        completion: @escaping SuccessCompletion) {
        
        let competitionEntry: AWSCompetitionEntry = AWSCompetitionEntry()
        competitionEntry._id = UUID.init().uuidString
        competitionEntry._userPoolUserId = CurrentUser.userPoolUserId
        competitionEntry._createDate = Date().iso8601
        competitionEntry._categoryId = NSNumber(integerLiteral: categoryType.rawValue)
        competitionEntry._competitionTypeId = NSNumber(integerLiteral: competitionType.rawValue)
        competitionEntry._caption = caption
        competitionEntry._videoPreviewImageId = videoPreviewImageId
        competitionEntry._videoId = videoId
        competitionEntry._imageId = imageId
        
        AWSDynamoDBObjectMapper.default().save(competitionEntry) { (error) in
            if let error = error {
                debugPrint("Error when creating competition entry: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("Competition entry successfully created.")
            completion(true)
        }
    }
}
