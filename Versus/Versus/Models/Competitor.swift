//
//  Competitor.swift
//  Versus
//
//  Created by JT Smrdel on 8/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation
import AVKit

enum CompetitorType: String {
    case first
    case second
}

class Competitor {
    
    private let s3BucketService = S3BucketService.instance
    private let rankCollection = RankCollection.instance
    
    var competitorType: CompetitorType
    var caption: String
    var commentCount: Int
    var competitionId: String
    var competitionEntryId: String
    var competitionTypeId: Int
    var mediaId: String
    var userId: String
    var username: String
    var userRankId: Int
    var voteCount: Int
    
    var profileImage: UIImage?
    var profileImageSmall: UIImage?
    var competitionImage: UIImage?
    var competitionImageSmall: UIImage?
    var video: AVURLAsset?
    
    var rank: Rank {
        return rankCollection.rankFor(rankId: userRankId)
    }
    
    var competitionType: CompetitionType {
        return CompetitionType(rawValue: competitionTypeId)!
    }
    
    /**
 
     */
    init(
        competitorType: CompetitorType,
        caption: String,
        commentCount: Int,
        competitionId: String,
        competitionEntryId: String,
        competitionTypeId: Int,
        mediaId: String,
        userId: String,
        username: String,
        userRankId: Int,
        voteCount: Int
    ) {
        self.competitorType = competitorType
        self.caption = caption
        self.commentCount = commentCount
        self.competitionId = competitionId
        self.competitionEntryId = competitionEntryId
        self.competitionTypeId = competitionTypeId
        self.mediaId = mediaId
        self.userId = userId
        self.username = username
        self.userRankId = userRankId
        self.voteCount = voteCount
    }
    
    
    /**
     
     */
    func getProfileImage(
        completion: @escaping (_ image: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard profileImage == nil else {
            completion(profileImage, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: userId,
            imageType: .regular
        ) { (image, customError) in
            self.profileImage = image
            completion(image, customError)
        }
    }
    
    
    /**
     
     */
    func getProfileImageSmall(
        completion: @escaping (_ image: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard profileImageSmall == nil else {
            completion(profileImageSmall, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: userId,
            imageType: .small
        ) { (image, customError) in
            self.profileImageSmall = image
            completion(image, customError)
        }
    }
    
    
    /**
     
     */
    func getCompetitionImage(
        completion: @escaping (_ image: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard competitionImage == nil else {
            completion(competitionImage, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: mediaId,
            imageType: .regular
        ) { (image, customError) in
            self.competitionImage = image
            completion(image, customError)
        }
    }
    
    
    /**
     
     */
    func getCompetitionImageSmall(
        completion: @escaping (_ image: UIImage?, _ customError: CustomError?) -> Void
    ) {
        guard competitionImageSmall == nil else {
            completion(competitionImageSmall, nil)
            return
        }
        s3BucketService.downloadImage(
            mediaId: mediaId,
            imageType: .small
        ) { (image, customError) in
            self.competitionImageSmall = image
            completion(image, customError)
        }
    }
    
    
    /**
     
     */
    func getCompetitionVideo(
        completion: @escaping (_ video: AVURLAsset?, _ customError: CustomError?) -> Void
    ) {
        guard video == nil else {
            completion(video, nil)
            return
        }
        s3BucketService.downloadVideo(
            mediaId: mediaId,
            bucketType: .video
        ) { (video, customError) in
            self.video = video
            completion(video, customError)
        }
    }
}

extension Competitor: Equatable {
    
    static func == (lhs: Competitor, rhs: Competitor) -> Bool {
        return lhs.userId == rhs.userId
    }
}
