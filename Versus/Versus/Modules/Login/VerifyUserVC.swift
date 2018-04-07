//
//  VerifyUserVC.swift
//  Versus
//
// Allows user to enter verification code sent to their email or phone number.
//
//  Created by JT Smrdel on 3/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
//import AWSCognitoIdentityProvider
//import AWSCognitoUserPoolsSignIn

class VerifyUserVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    
    // MARK: - Variables
    
    var awsUser: AWSCognitoIdentityUser!
    var signInCredentials: SignInCredentials!
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    // MARK: - Actions
    
    // Abort the signup process and transition back to LandingVC.
    // TODO:
    // - Display confirmation alert.
    // - Delete data already created for user.
    @IBAction func cancelButtonAction() {
        performSegue(withIdentifier: UNWIND_TO_LANDING, sender: nil)
    }
    
    
    @IBAction func submitButtonAction() {
        
//        guard let user = AWSCognitoIdentityUserPool.default().currentUser() else { return }
        
        guard inputDataIsValid() else { return }
        
        let verificationCode = verificationCodeTextField.text!
        
        awsUser.confirmSignUp(verificationCode, forceAliasCreation: true).continueWith(executor: AWSExecutor.mainThread(), block: { (response) -> Any? in
            if let error = response.error {
                debugPrint("Failed to auth user: \(error.localizedDescription)")
                return nil
            }
            debugPrint("User verified")
            
            self.createUser()
            
            return nil
        })
    }
    
    
    @IBAction func resendCodeButtonAction() {
        
    }
    
    
    // MARK: - Private Funtions
    
    private func inputDataIsValid() -> Bool {
        
        guard let code = verificationCodeTextField.text, !code.isEmpty else {
            
            // Display error
            
            return false
        }
        
        return true
    }
    
    private func signIn() {
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        let signInProvider: AWSSignInProvider = AWSCognitoUserPoolsSignInProvider.sharedInstance()
        AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName) { (result, error) in
            if let error = error {
                debugPrint("Failed to login: \(error.localizedDescription)")
            }
            self.createUser()
        }
    }
    
    private func createUser() {
//        guard let userPoolUserId = self.awsUser.username else {
//            debugPrint("AWS user username nil")
//            return
//        }
        guard let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username else {
            debugPrint("AWS user username nil")
            return
        }
        debugPrint("Current user username: \(username)")
        
        UserService.instance.createUser(userPoolUserId: username, username: "JTSmrd")
    }
}

extension VerifyUserVC: AWSCognitoUserPoolsSignInHandler {
    
    func handleUserPoolSignInFlowStart() {
        
//        guard let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username else {
//            debugPrint("AWS user username nil")
//            return
//        }
        
        passwordAuthenticationCompletion?.set(result: AWSCognitoIdentityPasswordAuthenticationDetails(username: signInCredentials.username, password: signInCredentials.password))
    }
}

extension VerifyUserVC: AWSCognitoIdentityPasswordAuthentication {
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        passwordAuthenticationCompletion = passwordAuthenticationCompletionSource as? AWSTaskCompletionSource<AnyObject>
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        if let error = error {
            debugPrint("Error password auth step: \(error.localizedDescription)")
        }
    }
}

extension VerifyUserVC: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        return self
    }
}
