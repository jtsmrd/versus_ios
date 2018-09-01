//
//  Leaderboard.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

enum LeaderboardType: Int {
    case weekly = 1
    case monthly = 2
    case allTime = 3
}

class Leaderboard {
    
    private(set) var awsLeaderboard: AWSLeaderboard!
    
    var isActive: Bool
    var name: String
    var numberOfResults: Int
    var leaderboardTypeId: Int
    
    var leaderboardType: LeaderboardType {
        return LeaderboardType(rawValue: leaderboardTypeId)!
    }
    
    var featuredLeaderUserId: String?
    var featuredLeaderImage: UIImage?
    var leaders = [Leader]()
    
    
    init(awsLeaderboard: AWSLeaderboard) {
        self.awsLeaderboard = awsLeaderboard
        
        self.isActive = awsLeaderboard._isActive?.boolValue ?? false
        self.name = awsLeaderboard._name ?? ""
        self.numberOfResults = awsLeaderboard._numberOfResults?.intValue ?? 0
        self.leaderboardTypeId = awsLeaderboard._leaderboardTypeId?.intValue ?? 0
    }
    
    
    func getLeaders(completion: @escaping SuccessErrorCompletion) {
        
        LeaderService.instance.getLeaders(for: self) { (leaders, customError) in
            if let customError = customError, let error = customError.error {
                debugPrint("Failed to load leaders: \(error.localizedDescription)")
                completion(false, customError)
            }
            else {
                self.leaders = leaders.sorted { (leader1, leader2) -> Bool in
                    return leader1.wins >= leader2.wins && leader1.votes > leader2.votes
                }
                self.featuredLeaderUserId = self.leaders.first?.userId
                completion(true, nil)
            }
        }
    }
    
    
    func getTopLeader(completion: @escaping SuccessCompletion) {
        
        guard featuredLeaderUserId == nil else {
            completion(true)
            return
        }
        
        LeaderService.instance.getTopLeader(for: self) { (leader, customError) in
            if let _ = customError {
                completion(false)
            }
            else if let leader = leader {
                self.featuredLeaderUserId = leader.userId
                completion(true)
            }
        }
    }
    
    
    func getFeaturedLeaderImage(completion: @escaping (_ image: UIImage?) -> Void) {
        
        guard featuredLeaderImage == nil else {
            completion(featuredLeaderImage)
            return
        }
        
        guard let leaderUserId = self.featuredLeaderUserId else {
            completion(nil)
            return
        }
        
        S3BucketService.instance.downloadImage(
            mediaId: leaderUserId,
            imageType: .small
        ) { (image, customError) in
            if let customError = customError {
                debugPrint(customError)
                completion(nil)
            }
            else {
                self.featuredLeaderImage = image
                completion(image)
            }
        }
    }
}
