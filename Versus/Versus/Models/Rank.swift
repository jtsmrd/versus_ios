//
//  Rank.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol RankType {
    var id: Int { get }
    var title: String { get }
    var requiredWins: Int { get }
    var requiredVotes: Int { get }
    var image: UIImage? { get }
}

enum Rank: Int, CaseIterable {
    case rookie = 1
    case star = 2
    case superStar = 3
    case legend = 4
    case hallOfFame = 5
    
    init(rankId: Int? = 0) {
        
        switch rankId {
            case 1: self = .rookie
            case 2: self = .star
            case 3: self = .superStar
            case 4: self = .legend
            case 5: self = .hallOfFame
            default: self = .rookie
        }
    }
}




extension Rank: RankType {
    
    
    var id: Int {
        
        switch self {
            
        case .rookie:
            return 1
            
        case .star:
            return 2
            
        case .superStar:
            return 3
            
        case .legend:
            return 4
            
        case .hallOfFame:
            return 5
        }
    }
    
    
    var title: String {
        
        switch self {
            
        case .rookie:
            return "Rookie"
            
        case .star:
            return "Star"
            
        case .superStar:
            return "Super Star"
            
        case .legend:
            return "Legend"
            
        case .hallOfFame:
            return "Hall of Fame"
        }
    }
    
    
    var requiredWins: Int {
        
        switch self {
            
        case .rookie:
            return 10
            
        case .star:
            return 50
            
        case .superStar:
            return 100
            
        case .legend:
            return 300
            
        case .hallOfFame:
            return 500
        }
    }
    
    
    var requiredVotes: Int {
        
        switch self {
            
        case .rookie:
            return 100
            
        case .star:
            return 1000
            
        case .superStar:
            return 10000
            
        case .legend:
            return 50000
            
        case .hallOfFame:
            return 100000
        }
    }
    
    
    var image: UIImage? {
        
        switch self {
            
        case .rookie:
            return UIImage(named: "Rookie")
            
        case .star:
            return UIImage(named: "Star")
            
        case .superStar:
            return UIImage(named: "SuperStar")
            
        case .legend:
            return UIImage(named: "Legend")
            
        case .hallOfFame:
            return UIImage(named: "Hall-of-Fame")
        }
    }
}
