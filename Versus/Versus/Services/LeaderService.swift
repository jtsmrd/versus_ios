//
//  LeaderService.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class LeaderService {
    
    static let instance = LeaderService()
    private let networkManager = NetworkManager()
    private let router = Router<LeaderEndpoint>()
    
    private init() { }
    
    
    func getWeeklyLeaders(
        completion: @escaping (_ leaders: [Leader], _ error: String?) -> ()
    ) {
        
        router.request(
            .getWeekly
        ) { (data, response, error) in
            
            var leaders = [Leader]()
            
            if error != nil {
                completion(leaders, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(leaders, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        leaders = try decoder.decode(
                            [Leader].self,
                            from: responseData
                        )
                        completion(leaders, nil)
                    }
                    catch {
                        completion(
                            leaders,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(leaders, networkFailureError)
                }
            }
        }
    }
    
    
    func getMonthlyLeaders(
        completion: @escaping (_ leaders: [Leader], _ error: String?) -> ()
    ) {
        
        router.request(
            .getMonthly
        ) { (data, response, error) in
            
            var leaders = [Leader]()
            
            if error != nil {
                completion(leaders, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(leaders, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        leaders = try decoder.decode(
                            [Leader].self,
                            from: responseData
                        )
                        completion(leaders, nil)
                    }
                    catch {
                        completion(
                            leaders,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(leaders, networkFailureError)
                }
            }
        }
    }
    
    
    func getAllTimeLeaders(
        completion: @escaping (_ leaders: [Leader], _ error: String?) -> ()
    ) {
        
        router.request(
            .getAllTime
        ) { (data, response, error) in
            
            var leaders = [Leader]()
            
            if error != nil {
                completion(leaders, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(leaders, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        leaders = try decoder.decode(
                            [Leader].self,
                            from: responseData
                        )
                        completion(leaders, nil)
                    }
                    catch {
                        completion(
                            leaders,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(leaders, networkFailureError)
                }
            }
        }
    }
}
