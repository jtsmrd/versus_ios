//
//  VoteService.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class VoteService {
    
    static let instance = VoteService()
    private let networkManager = NetworkManager()
    private let router = Router<VoteEndpoint>()
    
    private init() { }
    
    
    /**
     
     */
    func voteForEntry(
        entryId: Int,
        competitionId: Int,
        completion: @escaping (_ vote: Vote?, _ error: String?) -> ()
    ) {
        
        router.request(
            .create(
                entryId: entryId,
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
                        let vote = try decoder.decode(
                            Vote.self,
                            from: responseData
                        )
                        completion(vote, nil)
                    }
                    catch {
                        completion(
                            nil,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func deleteVote(
        voteId: Int,
        completion: @escaping (_ error: String?) -> Void
    ) {
        
        router.request(
            .delete(voteId: voteId)
        ) { (data, response, error) in
            
            if error != nil {
                completion("Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    completion(nil)
                    
                case .failure(let networkFailureError):
                    
                    completion(networkFailureError)
                }
            }
        }
    }
    
    
    func getVoteForCompetition(
        competitionId: Int,
        completion: @escaping (_ vote: Vote?, _ error: String?) -> Void
    ) {
        
        router.request(
            .get(competitionId: competitionId)
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
                    
                    let vote = try? decoder.decode(
                        Vote.self,
                        from: responseData
                    )
                    completion(vote, nil)
//                    do {
//                        let vote = try decoder.decode(
//                            Vote.self,
//                            from: responseData
//                        )
//                        completion(vote, nil)
//                    }
//                    catch {
//                        completion(
//                            nil,
//                            NetworkResponse.unableToDecode.rawValue
//                        )
//                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    /**
     
     */
    func updateVote(
        voteId: Int,
        entryId: Int,
        completion: @escaping (_ vote: Vote?, _ error: String?) -> Void
    ) {
        
        router.request(
            .update(
                voteId: voteId,
                entryId: entryId
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
                        let vote = try decoder.decode(
                            Vote.self,
                            from: responseData
                        )
                        completion(vote, nil)
                    }
                    catch {
                        completion(
                            nil,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
}
