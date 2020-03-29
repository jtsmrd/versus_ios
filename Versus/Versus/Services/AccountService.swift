//
//  AccountService.swift
//  Versus
//
//  Created by JT Smrdel on 4/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class AccountService {
    
    static let instance = AccountService()
    
    private let networkManager = NetworkManager()
    private let router = Router<AccountEndpoint>()
    
    private let userService = UserService.instance
    
    private init() { }
    
    
    
    /// Check if the given username is available.
    ///
    /// - Parameters:
    ///   - username: Username to check
    ///   - completion: available: Bool, (optional) error message.
    func checkUsernameAvailability(
        username: String,
        completion: @escaping (_ available: Bool, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .usernameAvailable(username: username)
        ) { (data, response, error) in
            
            if error != nil {
                completion(false, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(false, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                            let available = json["available"] as? Bool else {
                                completion(false, NetworkResponse.unableToDecode.rawValue)
                                return
                        }
                        completion(available, nil)
                    }
                    catch {
                        completion(false, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(false, networkFailureError)
                }
            }
        }
    }
    
    
    
    /// Sign up a new user.
    ///
    /// - Parameters:
    ///   - name: Full name
    ///   - username: Username
    ///   - email: Email
    ///   - password: Password
    ///   - retypedPassword: Retyped password
    ///   - completion: (optional) User | (optional) error message
    func signUp(
        name: String,
        username: String,
        email: String,
        password: String,
        retypedPassword: String,
        completion: @escaping (_ account: Account?, _ errorMessage: String?) -> Void
    ) {
        
        router.request(
            .create(
                name: name,
                email: email,
                username: username,
                password: password,
                retypedPassword: retypedPassword
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
                        let account = try decoder.decode(Account.self, from: responseData)
                        completion(account, nil)
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
    
    
    
    /// Login user with username and password.
    ///
    /// - Parameters:
    ///   - username: The users' username.
    ///   - password: The users' password.
    ///   - completion: (optional) error message.
    func login(
        username: String,
        password: String,
        completion: @escaping (_ account: Account?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .login(
                username: username,
                password: password
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
                        let account = try decoder.decode(Account.self, from: responseData)
                        completion(account, nil)
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
    
    
    
    /**
     
     */
    func verify(
        completion: @escaping SuccessErrorCompletion
    ) {
        //TODO
    }
    
    
    /**
     
     */
    func resendCode(
        completion: @escaping SuccessErrorCompletion
    ) {
        //TODO
    }
    
    
    /**
     
     */
    func signIn(
        completion: @escaping SuccessErrorCompletion
    ) {
        //TODO
    }
    
    
    /**
     
     */
    func resetPassword(
        completion: @escaping (_ successMessage: String?, _ customError: CustomError?) -> Void
    ) {
        //TODO
    }
    
    
    /**
     
     */
    func confirmPasswordChange(
        verificationCode: String,
        password: String,
        completion: @escaping SuccessErrorCompletion
    ) {
        //TODO
    }
    
    
    /**
     
     */
    func signOut(completion: @escaping (Bool) -> ()) {
        
        CurrentAccount.setToken(token: "")
        completion(true)
    }
}
