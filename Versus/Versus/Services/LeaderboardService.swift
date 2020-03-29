//
//  LeaderboardService.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class LeaderboardService {
    
    static let instance = LeaderboardService()
    private let networkManager = NetworkManager()
    private let router = Router<LeaderboardEndpoint>()
    
    private init() { }
    
    
    /**
 
     */
    func getLeaderboards(
        completion: @escaping (_ leaderboards: [Leaderboard], _ error: String?) -> ()
    ) {
        router.request(.getLeaderboards) { (data, response, error) in
            
            var leaderboards = [Leaderboard]()
            
            if error != nil {
                completion(leaderboards, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(leaderboards, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        leaderboards = try decoder.decode(
                            [Leaderboard].self,
                            from: responseData
                        )
                        completion(leaderboards, nil)
                    }
                    catch {
                        completion(
                            leaderboards,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(leaderboards, networkFailureError)
                }
            }
        }
    }
}
