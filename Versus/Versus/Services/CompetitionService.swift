//
//  CompetitionService.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class CompetitionService {
    
    
    static let instance = CompetitionService()
    
    private let networkManager = NetworkManager()
    private let router = Router<CompetitionEndpoint>()
    
    
    
    
    private init() { }
    
    
    
    
    /// Load new competitions for users that the given user follows.
    ///
    /// - Parameters:
    ///   - userId: User's id.
    ///   - completion: A collection of competitions or an error message.
    func loadFollowedUserCompetitions(
        userId: Int,
        completion: @escaping (_ competitions: [Competition]?, _ error: String?) -> ()
    ) {
        
        router.request(
            .loadFollowedUserCompetitions(
                userId: userId
            )
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let competitions = try decoder.decode([Competition].self, from: responseData)
                        completion(competitions, nil)
                    }
                    catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    
    
    /// Loads the latest featured competitions, optionally filtered
    /// by category.
    ///
    /// - Parameters:
    ///   - categoryId: (optional) The categoryId to filter competitions.
    ///   - completion: A collection of competitions or an error message.
    func loadFeaturedCompetitions(
        categoryId: Int?,
        completion: @escaping (_ competitions: [Competition], _ error: String?) -> ()
    ) {
       
        router.request(
            .loadFeaturedCompetitions(
                categoryId: categoryId
            )
        ) { (data, response, error) in
            
            var competitions = [Competition]()
            
            if error != nil {
                completion(competitions, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(
                            competitions,
                            NetworkResponse.noData.rawValue
                        )
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        competitions = try decoder.decode(
                            [Competition].self,
                            from: responseData
                        )
                        completion(competitions, nil)
                    }
                    catch {
                        completion(
                            competitions,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(competitions, networkFailureError)
                }
            }
        }
    }
    
    
    
    
    /// Loads competitions for the given userId.
    ///
    /// - Parameters:
    ///   - userId: The User's id.
    ///   - completion: A collection of competitions or an error message.
    func loadUserCompetitions(
        userId: Int,
        completion: @escaping (_ competitions: [Competition], _ error: String?) -> ()
    ) {
        
        router.request(
            .loadUserCompetitions(
                userId: userId
            )
        ) { (data, response, error) in
            
            var competitions = [Competition]()
            
            if error != nil {
                completion(
                    competitions,
                    "Please check your network connection."
                )
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(
                            competitions,
                            NetworkResponse.noData.rawValue
                        )
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        competitions = try decoder.decode(
                            [Competition].self,
                            from: responseData
                        )
                        completion(competitions, nil)
                    }
                    catch {
                        completion(
                            competitions,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(competitions, networkFailureError)
                }
            }
        }
    }
    
    
    
    
    /// Gets a specific competition.
    ///
    /// - Parameters:
    ///   - userId: The User's id.
    ///   - completion: A collection of competitions or an error message.
    func getCompetition(
        competitionId: Int,
        completion: @escaping (_ competition: Competition?, _ error: String?) -> ()
    ) {
        
        router.request(
            .getCompetition(
                competitionId: competitionId
            )
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let competition = try decoder.decode(Competition.self, from: responseData)
                        completion(competition, nil)
                    }
                    catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
}
