//
//  Competition.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum CompetitionUser: String {
    case user1
    case user2
}

class Competition {
    
    var awsCompetition: AWSCompetition!
    
    var user1ProfileImage: UIImage?
    var user1ProfileImageSmall: UIImage?
    var user1ProfileBackgroundImage: UIImage?
    var user1CompetitionImage: UIImage?
    var user1CompetitionImageSmall: UIImage?
    var user1CompetitionVideoPreviewImage: UIImage?
    var user1CompetitionVideoPreviewImageSmall: UIImage?
    
    var user2ProfileImage: UIImage?
    var user2ProfileImageSmall: UIImage?
    var user2ProfileBackgroundImage: UIImage?
    var user2CompetitionImage: UIImage?
    var user2CompetitionImageSmall: UIImage?
    var user2CompetitionVideoPreviewImage: UIImage?
    var user2CompetitionVideoPreviewImageSmall: UIImage?
    
    
    var competitionType: CompetitionType {
        get {
            return CompetitionType(rawValue: awsCompetition._competitionTypeId as! Int)!
        }
    }
    
    var competitionCategoryColor: UIColor {
        get {
            return CategoryCollection.instance.categoryColorFor(categoryTypeId: awsCompetition._categoryId as! Int)
        }
    }
    
    var competitionCategoryIconImage: UIImage? {
        get {
            return CategoryCollection.instance.categoryIconFor(categoryTypeId: awsCompetition._categoryId as! Int)
        }
    }
    
    var isExpired: Bool {
        guard let expireDate = awsCompetition._expireDate!.toISO8601Date else {
            debugPrint("Could not convert competition expire date, defaulting to expired")
            return true
        }
        return expireDate < Date()
    }
    
    var secondsUntilExpire: Int? {
        guard let expireDate = awsCompetition._expireDate!.toISO8601Date else {
            debugPrint("Could not convert competition expire date")
            return nil
        }
        return Date().seconds(until: expireDate)
    }
    
    init(awsCompetition: AWSCompetition) {
        self.awsCompetition = awsCompetition
    }
    
    
    // Returns the username for the specified CompetitionUser
    func username(for competitionUser: CompetitionUser) -> String {
        switch competitionUser {
        case .user1:
            return "@\(awsCompetition._user1Username!)"
        case .user2:
            return "@\(awsCompetition._user2Username!)"
        }
    }
    
    
    func userRankImage(for competitionUser: CompetitionUser) -> UIImage? {
        switch competitionUser {
        case .user1:
            return RankCollection.instance.rankIconFor(rankId: awsCompetition._user1RankId as! Int)
        case .user2:
            return RankCollection.instance.rankIconFor(rankId: awsCompetition._user2RankId as! Int)
        }
    }
    
    
    // Download the competition image corresponding to the competitionUser and bucketType
    func getCompetitionImage(
        for competitionUser: CompetitionUser,
        bucketType: S3BucketType,
        completion: @escaping (UIImage?, CustomError?) -> Void
    ) {
        
        // This shouldn't happen, unless the video bucket type is specified in code, which doesn't make sense
        guard bucketType != .competitionVideo else {
            completion(nil, nil)
            return
        }
        
        // If the image was already downloaded, return the existing image
        var existingImage: UIImage?
        switch competitionUser {
        case .user1:
            
            switch bucketType {
            case .profileImage:
                existingImage = user1ProfileImage
            case .profileImageSmall:
                existingImage = user1ProfileImageSmall
            case .profileBackgroundImage:
                existingImage = user1ProfileBackgroundImage
            case .competitionImage:
                existingImage = user1CompetitionImage
            case .competitionImageSmall:
                existingImage = user1CompetitionImageSmall
            case .competitionVideoPreviewImage:
                existingImage = user1CompetitionVideoPreviewImage
            case .competitionVideoPreviewImageSmall:
                existingImage = user1CompetitionVideoPreviewImageSmall
            case .competitionVideo:
                break
            }
            
        case .user2:
            
            switch bucketType {
            case .profileImage:
                existingImage = user2ProfileImage
            case .profileImageSmall:
                existingImage = user2ProfileImageSmall
            case .profileBackgroundImage:
                existingImage = user2ProfileBackgroundImage
            case .competitionImage:
                existingImage = user2CompetitionImage
            case .competitionImageSmall:
                existingImage = user2CompetitionImageSmall
            case .competitionVideoPreviewImage:
                existingImage = user2CompetitionVideoPreviewImage
            case .competitionVideoPreviewImageSmall:
                existingImage = user2CompetitionVideoPreviewImageSmall
            case .competitionVideo:
                break
            }
        }
        
        if let image = existingImage {
            completion(image, nil)
            return
        }
        
        CompetitionService.instance.getCompetitionImage(
            for: competitionUser,
            competition: self,
            bucketType: bucketType
        ) { (image, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Could not download competition image."))
            }
            else if let image = image {
                
                switch competitionUser {
                case .user1:
                    
                    switch bucketType {
                    case .profileImage:
                        self.user1ProfileImage = image
                    case .profileImageSmall:
                        self.user1ProfileImageSmall = image
                    case .profileBackgroundImage:
                        self.user1ProfileBackgroundImage = image
                    case .competitionImage:
                        self.user1CompetitionImage = image
                    case .competitionImageSmall:
                        self.user1CompetitionImageSmall = image
                    case .competitionVideoPreviewImage:
                        self.user1CompetitionVideoPreviewImage = image
                    case .competitionVideoPreviewImageSmall:
                        self.user1CompetitionVideoPreviewImageSmall = image
                    case .competitionVideo:
                        break
                    }
                    
                case .user2:
                    
                    switch bucketType {
                    case .profileImage:
                        self.user2ProfileImage = image
                    case .profileImageSmall:
                        self.user2ProfileImageSmall = image
                    case .profileBackgroundImage:
                        self.user2ProfileBackgroundImage = image
                    case .competitionImage:
                        self.user2CompetitionImage = image
                    case .competitionImageSmall:
                        self.user2CompetitionImageSmall = image
                    case .competitionVideoPreviewImage:
                        self.user2CompetitionVideoPreviewImage = image
                    case .competitionVideoPreviewImageSmall:
                        self.user2CompetitionVideoPreviewImageSmall = image
                    case .competitionVideo:
                        break
                    }
                }
                completion(image, nil)
            }
        }
    }
}
