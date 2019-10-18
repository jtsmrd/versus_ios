//
//  CompetitionManager.swift
//  Versus
//
//  Created by JT Smrdel on 6/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class CompetitionManager {
    
    
    static let instance = CompetitionManager()
    
    var featuredCompetitions = [Competition]()
    
    
    
    
    private init() { }
    
    
    
    
    func getFeaturedCompetitions(
        completion: @escaping (_ competitions: [Competition], _ customError: CustomError?) -> Void
    ) {
        
//        CompetitionService.instance.getFeaturedCompetitions(
//            categoryId: nil
//        ) { (competitions, customError) in
//            if let customError = customError {
//                completion(self.featuredCompetitions, customError)
//                return
//            }
//            // Don't get Competitions that already exist
//            for competition in competitions {
//                if !self.featuredCompetitions.contains(where: { $0.competitionId == competition.competitionId }) {
//                    self.featuredCompetitions.append(competition)
//                }
//            }
//            completion(self.featuredCompetitions, nil)
//        }
    }
}
