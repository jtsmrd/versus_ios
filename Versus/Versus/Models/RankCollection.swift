//
//  RankCollection.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class RankCollection {
    
    static let instance = RankCollection()
    var ranks = [Rank]()
    
    private init() {
        configureRanks()
    }
    
    private func configureRanks() {
        
        let rank1 = Rank(id: 1, imageName: "Rookie", title: "Rookie", requiredWins: 10, requiredVotes: 100)
        let rank2 = Rank(id: 2, imageName: "Star", title: "Star", requiredWins: 50, requiredVotes: 1000)
        let rank3 = Rank(id: 3, imageName: "SuperStar", title: "Super Star", requiredWins: 100, requiredVotes: 10000)
        let rank4 = Rank(id: 4, imageName: "Legend", title: "Legend", requiredWins: 300, requiredVotes: 50000)
        let rank5 = Rank(id: 5, imageName: "Hall-of-Fame", title: "Hall of Fame", requiredWins: 500, requiredVotes: 100000)
        ranks.append(contentsOf: [rank5, rank4, rank3, rank2, rank1])
    }
}

struct Rank {
    
    var id: Int
    var imageName: String
    var title: String
    var requiredWins: Int
    var requiredVotes: Int
}
