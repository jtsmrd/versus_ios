//
//  AccountService.swift
//  Versus
//
//  Created by JT Smrdel on 4/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSAuthCore
import AWSDynamoDB
import AWSUserPoolsSignIn

class AccountService {
    
    static let instance = AccountService()
    var signInCredentials: SignInCredentials?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    private init() { }
    
    func signUp(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        var responseTask: AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>!
        let signUpDispatchGroup = DispatchGroup()
        
        signUpDispatchGroup.enter()
        AWSCognitoIdentityUserPool.default().signUp(
            username,
            password: password,
            userAttributes: nil,
            validationData: nil
        ).continueWith { (task) -> Any? in
            responseTask = task
            signUpDispatchGroup.leave()
            return nil
        }
        
        signUpDispatchGroup.notify(queue: .main) {
            if let error = responseTask.error {
                debugPrint("Failed to create user: \(error.localizedDescription)")
                completion(false)
            }
            else if let _ = responseTask.result?.user {
                debugPrint("Successfully created user")
                completion(true)
            }
        }
    }
    
    
    func verify() {
        
    }
    
    
    func signIn(signInCredentials: SignInCredentials) {
        
//        self.signInCredentials = signInCredentials
//        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
//        let signInProvider: AWSSignInProvider = AWSCognitoUserPoolsSignInProvider.sharedInstance()
//        AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName) { (result, error) in
//            if let error = error {
//                debugPrint("Failed to login: \(error.localizedDescription)")
//                return
//            }
//        }
    }
    
    
    func checkAvailability(for username: String, completion: @escaping (_ isAvailable: Bool) -> Void) {
        
        let queryExpression = AWSDynamoDBQueryExpression()

        queryExpression.keyConditionExpression = "#username = :username"
        queryExpression.expressionAttributeNames = ["#username": "username"]
        queryExpression.expressionAttributeValues = [":username" : username]
        
        var responseTask: AWSTask<AWSDynamoDBPaginatedOutput>!
        let availabilityDispatchGroup = DispatchGroup()
        
        availabilityDispatchGroup.enter()
        AWSDynamoDBObjectMapper.default().query(
            User.self,
            expression: queryExpression
        ).continueWith { (task) -> Any? in
            responseTask = task
            availabilityDispatchGroup.leave()
            return nil
        }
        
        availabilityDispatchGroup.notify(queue: .main) {
            if let error = responseTask.error {
                debugPrint("Error checking usernames: \(error.localizedDescription)")
                completion(false)
            }
            else if let result = responseTask.result {
                let users = result.items
                debugPrint("Users: \(users)")
                if users.count == 0 {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
    }
    
    
    func signOut(completion: @escaping (Bool) -> ()) {
        AWSCognitoIdentityUserPool.default().currentUser()?.signOut()
        completion(true)
    }
}