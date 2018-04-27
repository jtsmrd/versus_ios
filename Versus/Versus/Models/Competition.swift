//
//  Competition.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class Competition {
    
    var awsCompetition: AWSCompetition!
    var user1CompetitionImageSmall: UIImage?
    var user1CompetitionImage: UIImage?
    var user2CompetitionImageSmall: UIImage?
    var user2CompetitionImage: UIImage?
    var user1ProfileImage: UIImage?
    var user2ProfileImage: UIImage?
    
    var user1Username: String {
        get {
            return "@\(awsCompetition._user1Username!)"
        }
    }
    
    var user2Username: String {
        get {
            return "@\(awsCompetition._user2Username!)"
        }
    }
    
    var user1RankImage: UIImage? {
        get {
            return RankCollection.instance.rankIconFor(rankId: awsCompetition._user1RankId as! Int)
        }
    }
    
    var user2RankImage: UIImage? {
        get {
            return RankCollection.instance.rankIconFor(rankId: awsCompetition._user2RankId as! Int)
        }
    }
    
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
    
    init(awsCompetition: AWSCompetition) {
        self.awsCompetition = awsCompetition
    }
    
    func getUser1ProfileImage(completion: @escaping (UIImage?) -> Void) {
        guard user1ProfileImage == nil else {
            completion(user1ProfileImage)
            return
        }
        S3BucketService.instance.downloadImage(imageName: awsCompetition._user1userPoolUserId!, bucketType: .profileImage) { (image, error) in
            if let error = error {
                debugPrint("Could not download user1 profile image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.user1ProfileImage = image
                completion(image)
            }
        }
    }
    
    func getUser2ProfileImage(completion: @escaping (UIImage?) -> Void) {
        guard user2ProfileImage == nil else {
            completion(user2ProfileImage)
            return
        }
        S3BucketService.instance.downloadImage(imageName: awsCompetition._user2userPoolUserId!, bucketType: .profileImage) { (image, error) in
            if let error = error {
                debugPrint("Could not download user2 profile image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.user2ProfileImage = image
                completion(image)
            }
        }
    }
    
    func getUser1CompetitionImageSmall(completion: @escaping (UIImage?) -> Void) {
        guard user1CompetitionImageSmall == nil else {
            completion(user1CompetitionImageSmall)
            return
        }
        S3BucketService.instance.downloadImage(imageName: awsCompetition._user1ImageSmallId!, bucketType: .competitionImageSmall) { (image, error) in
            if let error = error {
                debugPrint("Could not download user1 competition image small: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.user1CompetitionImageSmall = image
                completion(image)
            }
        }
    }
    
    func getUser1CompetitionImage(completion: @escaping (UIImage?) -> Void) {
        guard user1CompetitionImage == nil else {
            completion(user1CompetitionImage)
            return
        }
        S3BucketService.instance.downloadImage(imageName: awsCompetition._user1ImageId!, bucketType: .competitionImage) { (image, error) in
            if let error = error {
                debugPrint("Could not download user1 competition image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.user1CompetitionImage = image
                completion(image)
            }
        }
    }
    
    func getUser2CompetitionImageSmall(completion: @escaping (UIImage?) -> Void) {
        guard user2CompetitionImageSmall == nil else {
            completion(user2CompetitionImageSmall)
            return
        }
        S3BucketService.instance.downloadImage(imageName: awsCompetition._user2ImageSmallId!, bucketType: .competitionImageSmall) { (image, error) in
            if let error = error {
                debugPrint("Could not download user2 competition image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.user2CompetitionImageSmall = image
                completion(image)
            }
        }
    }
    
    func getUser2CompetitionImage(completion: @escaping (UIImage?) -> Void) {
        guard user2CompetitionImage == nil else {
            completion(user2CompetitionImage)
            return
        }
        S3BucketService.instance.downloadImage(imageName: awsCompetition._user2ImageId!, bucketType: .competitionImage) { (image, error) in
            if let error = error {
                debugPrint("Could not download user2 competition image: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                self.user2CompetitionImage = image
                completion(image)
            }
        }
    }
}
