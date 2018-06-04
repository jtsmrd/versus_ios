//
//  CompetitionManager.swift
//  Versus
//
//  Created by JT Smrdel on 6/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

class CompetitionManager {
    
    static let instance = CompetitionManager()
    
    var featuredCompetitions = [Competition]()
    
    private init() { }
    
    func getFeaturedCompetitions(
        completion: @escaping (_ competitions: [Competition], _ error: CustomError?) -> Void) {
        
        CompetitionService.instance.getFeaturedCompetitions { (competitions, error) in
            if let error = error {
                completion(self.featuredCompetitions, error)
            }
            else {
                
                // Don't get Competitions that already exist
                for competition in competitions {
                    if !self.featuredCompetitions.contains(where: { $0.awsCompetition._id == competition.awsCompetition._id }) {
                        self.featuredCompetitions.append(competition)
                    }
                }
                completion(self.featuredCompetitions, nil)
            }
        }
    }
}
