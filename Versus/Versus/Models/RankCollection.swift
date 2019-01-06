//
//  RankCollection.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class RankCollection {
    
    static let instance = RankCollection()
    private(set) var ranks = [Rank]()
    private var rank1: Rank!
    private var rank2: Rank!
    private var rank3: Rank!
    private var rank4: Rank!
    private var rank5: Rank!
    
    private init() {
        configureRanks()
    }
    
    private func configureRanks() {
        
        rank1 = Rank(id: 1, imageName: "Rookie", title: "Rookie", requiredWins: 10, requiredVotes: 100)
        rank2 = Rank(id: 2, imageName: "Star", title: "Star", requiredWins: 50, requiredVotes: 1000)
        rank3 = Rank(id: 3, imageName: "SuperStar", title: "Super Star", requiredWins: 100, requiredVotes: 10000)
        rank4 = Rank(id: 4, imageName: "Legend", title: "Legend", requiredWins: 300, requiredVotes: 50000)
        rank5 = Rank(id: 5, imageName: "Hall-of-Fame", title: "Hall of Fame", requiredWins: 500, requiredVotes: 100000)
        ranks.append(contentsOf: [rank5, rank4, rank3, rank2, rank1])
    }
    
    func rankIconFor(rankId: Int) -> UIImage? {
        if let rank = ranks.first(where: {$0.id == rankId}) {
            return UIImage(named: rank.imageName)
        }
        return nil
    }
    
    func rankFor(rankId: Int) -> Rank {
        if let rank = ranks.first(where: { $0.id == rankId }) {
            return rank
        }
        return rank1
    }
}

struct Rank {
    
    var id: Int
    var imageName: String
    var title: String
    var requiredWins: Int
    var requiredVotes: Int
    var image: UIImage? {
        return UIImage(named: imageName)
    }
}
