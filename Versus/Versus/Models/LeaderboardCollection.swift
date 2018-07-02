//
//  LeaderboardCollection.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class LeaderboardCollection {
    
    static let instance = LeaderboardCollection()
    
    var leaderboards = [Leaderboard]()
    
    private init() { }
    
    func getLeaderboards(completion: @escaping SuccessErrorCompletion) {
        
        LeaderboardService.instance.getLeaderboards { (leaderboards, customError) in
            if let customError = customError, let error = customError.error {
                debugPrint("Failed to load leaderboards: \(error.localizedDescription)")
                completion(false, customError)
            }
            else {
                self.leaderboards = leaderboards.sorted(by: { $0.leaderboardType.rawValue < $1.leaderboardType.rawValue })
                completion(true, nil)
            }
        }
    }
}
