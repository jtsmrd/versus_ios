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
    
    var signInCredentials: SignInCredentials!
    var keyboardToolbar: KeyboardToolbar!
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInCredentials = CurrentUser.getSignInCredentials()
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
    }
    
    
    // MARK: - Actions
    
    // Abort the signup process and transition back to LandingVC.
    // TODO:
    // - Display confirmation alert.
    // - Delete data already created for user.
    @IBAction func cancelButtonAction() {
        displayCancelAlert()
    }
    
    
    @IBAction func submitButtonAction() {
        
        guard inputDataIsValid() else { return }
        
        let confirmationCode = verificationCodeTextField.text!
        
        let awsUser = AWSCognitoIdentityUserPool.default().getUser(signInCredentials.username)
        
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
    
    private func displayCancelAlert() {
        let cancelAlertController = UIAlertController(title: "Cancel signup?", message: "Are you sure you want to cancel?", preferredStyle: .alert)
        cancelAlertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let awsUser = AWSCognitoIdentityUserPool.default().getUser(self.signInCredentials.username)
            awsUser.delete()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: UNWIND_TO_LANDING, sender: nil)
            }
        }))
        cancelAlertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
        }))
        present(cancelAlertController, animated: true, completion: nil)
    }
}

extension VerifyUserVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
}
