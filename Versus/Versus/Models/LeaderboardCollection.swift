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
    
    private let leaderboardService = LeaderboardService.instance
    
    var leaderboards = [Leaderboard]()
    
    private init() { }
    
    func getLeaderboards(
        completion: @escaping (_ leaderboards: [Leaderboard], _ error: String?) -> ()
    ) {
        
        leaderboardService.getLeaderboards { (leaderboards, error) in
            
            self.leaderboards = leaderboards.sorted(
                by: { $0.type.id < $1.type.id }
            )
            
            completion(self.leaderboards, error)
        }
    }
}
