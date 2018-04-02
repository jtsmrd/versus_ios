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
            }
            else {
                debugPrint("Successfully authenticated user")
            }
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
}
