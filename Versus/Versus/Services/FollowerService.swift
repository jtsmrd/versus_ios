//
//  FollowerService.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class FollowerService {
    
    static let instance = FollowerService()
    
    private let networkManager = NetworkManager()
    private let router = Router<FollowerEndpoint>()
    
    
    private init() { }
    
    
    
    func followUser(
        userId: Int,
        completion: @escaping (_ error: String?) -> ()
    ) {
        
        router.request(
            .followUser(
                userId: userId
            )
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
    
    
    
    func getFollowedUser(
        userId: Int,
        followedUserId: Int,
        completion: @escaping (_ followedUser: Follower?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .getFollowedUser(
                userId: userId,
                followedUserId: followedUserId
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
                        let followedUsers = try decoder.decode([Follower].self, from: responseData)
                        
                        guard let followedUser = followedUsers.first else {
                            completion(nil, NetworkResponse.noData.rawValue)
                            return
                        }
                        completion(followedUser, nil)
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
    
    
    
    func loadFollowedUsers(
        userId: Int,
        completion: @escaping (_ followedUsers: [Follower]?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .loadFollowedUsers(
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
                        let followers = try decoder.decode([Follower].self, from: responseData)
                        completion(followers, nil)
                    }
                    catch {
                        debugPrint(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    
    func loadFollowers(
        userId: Int,
        completion: @escaping (_ followers: [Follower]?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .loadFollowers(
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
                        let followers = try decoder.decode([Follower].self, from: responseData)
                        completion(followers, nil)
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
    
    
    
    func unfollow(
        followerId: Int,
        completion: @escaping (_ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .unfollow(
                followerId: followerId
            )
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
}
