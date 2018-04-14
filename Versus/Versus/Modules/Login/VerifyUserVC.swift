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

class VerifyUserVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    // MARK: - Variables
    
    var awsUser: AWSCognitoIdentityUser!
    var signInCredentials: SignInCredentials!
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func initData(awsUser: AWSCognitoIdentityUser, signInCredentials: SignInCredentials) {
        self.awsUser = awsUser
        self.signInCredentials = signInCredentials
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
        
        guard inputDataIsValid() else { return }
        
        let confirmationCode = verificationCodeTextField.text!
        
        AccountService.instance.verify(
            awsUser: awsUser,
            confirmationCode: confirmationCode
        ) { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if success {
                    self.signIn()
                }
            }
        }
    }
    
    
    @IBAction func resendCodeButtonAction() {
        
        AccountService.instance.resendCode { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if success {
                    self.displayMessage(message: "Code resent")
                }
            }
        }
    }
    
    
    // MARK: - Private Funtions
    
    private func inputDataIsValid() -> Bool {
        
        guard let code = verificationCodeTextField.text, !code.isEmpty else {
            displayMessage(message: "Enter your verification code")
            return false
        }
        
        return true
    }
    
    private func signIn() {
        
        AccountService.instance.signIn(
            signInCredentials: signInCredentials
        ) { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if success {
                    self.performSegue(withIdentifier: SHOW_CHOOSE_USERNAME, sender: nil)
                }
            }
        }
    }
}
