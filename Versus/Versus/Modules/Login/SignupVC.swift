//
//  SignupVC.swift
//  Versus
//
// Creates a new identity (in User Pool) via email or phone number.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class SignupVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var emailPhoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: RoundButton!
    
    
    // MARK: - Variables
    
    var signupMethod: SignupMethod = .email
    var signInCredentials: SignInCredentials!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch signupMethod {
        case .email:
            emailPhoneNumberTextField.placeholder = "Email"
        case .phoneNumber:
            emailPhoneNumberTextField.placeholder = "Phone number"
        }
    }

    
    // MARK: - Required Functions
    
    func initData(signupMethod: SignupMethod) {
        self.signupMethod = signupMethod
    }
    
    
    // MARK: - Actions
    
    // Transitions back to LandingVC
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // Created a new identity (in User Pool) via email or phone then transitions to VerifyUserVC.
    // TODO:
    // - Authenticate using AWS Cognito via email or phone.
    @IBAction func signupButtonAction() {
        
        guard inputDataIsValid() else { return }
        
        let username = emailPhoneNumberTextField.text!
        let password = passwordTextField.text!
        
        signInCredentials = SignInCredentials(username: username, password: password)
        
        AccountService.instance.signUp(username: username, password: password) { (awsUser, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if let awsUser = awsUser {
                    self.performSegue(withIdentifier: SHOW_VERIFY_USER, sender: awsUser)
                }
            }
        }
    }
    
    
    @IBAction func alreadyHaveCodeButtonAction() {
        performSegue(withIdentifier: SHOW_VERIFY_USER, sender: nil)
    }
    
    
    // MARK: - Private Funtions
    
    // Validate email or phone number and password prior to attempting to create a new user
    // TODO:
    // - If signup method is email, validate email.
    // - If signup method is phone number, validate phone number.
    // Valid phone numbers are strings prefixed with '+' and the international code. ex: +14128885555
    private func inputDataIsValid() -> Bool {
        
        guard let emailPhoneNumber = emailPhoneNumberTextField.text, !emailPhoneNumber.isEmpty else {
            switch signupMethod {
            case .email:
                displayMessage(message: "Provide a valid email")
            case .phoneNumber:
                displayMessage(message: "Provide a valid phone number")
            }
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(message: "Provide a valid password")
            return false
        }
        
        return true
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verifyAccountVC = segue.destination as? VerifyUserVC, let awsUser = sender as? AWSCognitoIdentityUser {
            verifyAccountVC.initData(awsUser: awsUser, signInCredentials: signInCredentials)
        }
    }
}
