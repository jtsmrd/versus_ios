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
    
    var leaderboardType: LeaderboardType {
        return LeaderboardType(rawValue: awsLeaderboard._leaderboardTypeId!.intValue)!
    }
    
    var leaderboardName: String {
        return awsLeaderboard._leaderboardName!
    }
    
    var numberOfResults: Int {
        return awsLeaderboard._numberOfResults!.intValue
    }
    
    var featuredLeaderUserPoolUserId: String?
    var featuredLeaderImage: UIImage?
    var leaders = [Leader]()
    
    
    init(awsLeaderboard: AWSLeaderboard) {
        self.awsLeaderboard = awsLeaderboard
    }
    
    
    func getLeaders(completion: @escaping SuccessErrorCompletion) {
        
        LeaderService.instance.getLeaders(for: self) { (leaders, customError) in
            if let customError = customError, let error = customError.error {
                debugPrint("Failed to load leaders: \(error.localizedDescription)")
                completion(false, customError)
            }
            else {
                self.leaders = leaders.sorted { (leader1, leader2) -> Bool in
                    return leader1.totalWins >= leader2.totalWins && leader1.totalVotes > leader2.totalVotes
                }
                self.featuredLeaderUserPoolUserId = self.leaders.first?.userPoolUserId
                completion(true, nil)
            }
        }
    }
    
    
    func getTopLeader(completion: @escaping SuccessCompletion) {
        
        guard featuredLeaderUserPoolUserId == nil else {
            completion(true)
            return
        }
        
        LeaderService.instance.getTopLeader(for: self) { (leader, customError) in
            if let _ = customError {
                completion(false)
            }
            else if let leader = leader {
                self.featuredLeaderUserPoolUserId = leader.userPoolUserId
                completion(true)
            }
        }
    }
    
    
    func getFeaturedLeaderImage(completion: @escaping (_ image: UIImage?) -> Void) {
        
        guard featuredLeaderImage == nil else {
            completion(featuredLeaderImage)
            return
        }
        
        guard let leaderUserPoolUserId = self.featuredLeaderUserPoolUserId else {
            completion(nil)
            return
        }
        
        S3BucketService.instance.downloadImage(
            imageName: leaderUserPoolUserId,
            bucketType: .profileImageSmall
        ) { (image, error) in
            if let error = error {
                debugPrint("Failed to download featured leaderboard image: \(error.localizedDescription)")
                completion(nil)
            }
            else {
                self.featuredLeaderImage = image
                completion(image)
            }
        }
    }
}
