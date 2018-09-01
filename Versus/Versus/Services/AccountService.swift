//
//  AccountService.swift
//  Versus
//
//  Created by JT Smrdel on 4/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSAuthCore
import AWSUserPoolsSignIn

class AccountService {
    
    static let instance = AccountService()
    private let cognito = AWSCognitoIdentityUserPool.default()
    private let signInManager = AWSSignInManager.sharedInstance()
    
    var signInCredentials: SignInCredentials?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    private init() { }
    
    
    /**
     
     */
    func signUp(
        username: String,
        password: String,
        completion: @escaping (_ user: AWSCognitoIdentityUser?, _ error: CustomError?) -> Void
    ) {
        var responseTask: AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>!
        let signUpDispatchGroup = DispatchGroup()
        
        signUpDispatchGroup.enter()
        cognito.signUp(
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
            var errorMessage = "Unable to sign up, try again"
            
            if let error = responseTask.error {
                debugPrint("Failed to create user: \(error.localizedDescription)")
                
                if error.localizedDescription.contains("37") {
                    errorMessage = "Email already exists"
                }
                else if error.localizedDescription.contains("14") {
                    errorMessage = "Invalid password"
                }
                
                completion(nil, CustomError(error: error, message: errorMessage))
            }
            else if let user = responseTask.result?.user {
                debugPrint("Successfully created user")
                completion(user, nil)
            }
            else {
                debugPrint("Failed to create user")
                completion(nil, CustomError(error: nil, message: errorMessage))
            }
        }
    }
    
    
    /**
     
     */
    func verify(
        awsUser: AWSCognitoIdentityUser,
        confirmationCode: String,
        completion: @escaping SuccessErrorCompletion
    ) {
        var responseTask: AWSTask<AWSCognitoIdentityUserConfirmSignUpResponse>!
        let verifyDispatchGroup = DispatchGroup()
        
        verifyDispatchGroup.enter()
        awsUser.confirmSignUp(
            confirmationCode,
            forceAliasCreation: true
        ).continueWith { (task) -> Any? in
            responseTask = task
            verifyDispatchGroup.leave()
            return nil
        }
        
        verifyDispatchGroup.notify(queue: .main) {
            var errorMessage = "Unable to verify user, try again"
            
            if let error = responseTask.error {
                debugPrint("Failed to verify user: \(error.localizedDescription)")
                
                if error.localizedDescription.contains("20") {
                    errorMessage = "Invalid verification code"
                }
                completion(false, CustomError(error: error, message: errorMessage))
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    
    /**
     
     */
    func resendCode(
        completion: @escaping SuccessErrorCompletion
    ) {
        guard let awsUser = cognito.currentUser() else {
            completion(false, nil)
            return
        }
        
        var responseTask: AWSTask<AWSCognitoIdentityUserResendConfirmationCodeResponse>!
        let resendCodeDispatchGroup = DispatchGroup()
        
        resendCodeDispatchGroup.enter()
        awsUser.resendConfirmationCode()
        .continueWith { (task) -> Any? in
            responseTask = task
            resendCodeDispatchGroup.leave()
            return nil
        }
        
        resendCodeDispatchGroup.notify(queue: .main) {
            var errorMessage = "Unable to resend code, try again"
            
            if let error = responseTask.error {
                debugPrint("Failed to resend code: \(error.localizedDescription)")
                
                if error.localizedDescription.contains("20") {
                    errorMessage = "Invalid verification code"
                }
                completion(false, CustomError(error: error, message: errorMessage))
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    
    /**
     
     */
    func signIn(
        signInCredentials: SignInCredentials,
        completion: @escaping SuccessErrorCompletion
    ) {
        appDelegate.prepareForSignIn(signInCredentials: signInCredentials)
        let signInProvider: AWSSignInProvider = AWSCognitoUserPoolsSignInProvider.sharedInstance()
        
        signInManager.login(
            signInProviderKey: signInProvider.identityProviderName
        ) { (result, error) in
            if let error = error {
                debugPrint("Failed to login: \(error.localizedDescription)")
                completion(false, CustomError(error: error, message: "Unable to login user"))
            }
            else {
                CurrentUser.clearSignupCredentials()
                completion(true, nil)
            }
        }
    }
    
    
    /**
     
     */
    func getEmail(
        completion: @escaping (String) -> Void
    ) {
        let getEmailDispatchGroup = DispatchGroup()
        let currentUser = cognito.currentUser()
        var userEmail = ""
        
        getEmailDispatchGroup.enter()
        currentUser?.getDetails().continueWith(
            executor: AWSExecutor.mainThread(),
            block: { (response) -> Any? in
                if let error = response.error {
                    debugPrint("Error getting user details: \(error.localizedDescription)")
                    getEmailDispatchGroup.leave()
                }
                else if let result = response.result {
                    if let attributes = result.userAttributes {
                        for attribute in attributes {
                            if let attributeName = attribute.name, attributeName == "email" {
                                if let email = attribute.value {
                                    userEmail = email
                                    getEmailDispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
                return nil
            }
        )
        getEmailDispatchGroup.notify(queue: .main) {
            completion(userEmail)
        }
    }
    
    
    /**
     
     */
    func resetPassword(
        user: AWSCognitoIdentityUser,
        completion: @escaping (_ successMessage: String?, _ customError: CustomError?) -> Void
    ) {
        let resetPasswordDispatchGroup = DispatchGroup()
        var responseTask: AWSTask<AWSCognitoIdentityUserForgotPasswordResponse>!
        
        resetPasswordDispatchGroup.enter()
        user.forgotPassword().continueWith(
            executor: AWSExecutor.mainThread()
        ) { (response) -> Any? in
            responseTask = response
            resetPasswordDispatchGroup.leave()
            return nil
        }
        
        resetPasswordDispatchGroup.notify(queue: .main) {
            if let error = responseTask.error {
                completion(nil, CustomError(error: error, message: "Unable to reset password"))
            }
            else if let result = responseTask.result, let deliveryDetails = result.codeDeliveryDetails {
                switch deliveryDetails.deliveryMedium {
                case .email:
                    completion("A verification code has been sent to your email", nil)
                case .sms:
                    completion("A verification code has been sent to your phone", nil)
                case .unknown:
                    completion(nil, CustomError(error: nil, message: "Unable to reset password"))
                }
            }
        }
    }
    
    
    /**
     
     */
    func confirmPasswordChange(
        user: AWSCognitoIdentityUser,
        verificationCode: String,
        password: String,
        completion: @escaping SuccessErrorCompletion
    ) {
        let confirmForgotPasswordDispatchGroup = DispatchGroup()
        var responseTask: AWSTask<AWSCognitoIdentityUserConfirmForgotPasswordResponse>!
        
        confirmForgotPasswordDispatchGroup.enter()
        user.confirmForgotPassword(
            verificationCode,
            password: password
        ).continueWith(
            executor: AWSExecutor.mainThread()
        ) { (response) -> Any? in
            responseTask = response
            confirmForgotPasswordDispatchGroup.leave()
            return nil
        }
        
        confirmForgotPasswordDispatchGroup.notify(queue: .main) {
            if let error = responseTask.error {
                completion(false, CustomError(error: error, message: "Unable to change password"))
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    
    /**
     
     */
    func signOut(completion: @escaping (Bool) -> ()) {
        cognito.currentUser()?.signOut()
        cognito.clearAll()
        completion(true)
    }
}
