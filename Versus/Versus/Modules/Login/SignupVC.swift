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
        
        if inputDataIsValid() {
            
            let username = emailPhoneNumberTextField.text!
            let password = passwordTextField.text!
            
            signInCredentials = SignInCredentials(username: username, password: password)
            
            var attributes = [AWSCognitoIdentityUserAttributeType]()
            
            let email = AWSCognitoIdentityUserAttributeType()!
            email.name = "email"
            email.value = username
            attributes.append(email)
            
            AWSCognitoIdentityUserPool.default().signUp("smrddddd", password: password, userAttributes: attributes, validationData: nil)
                .continueWith(executor: AWSExecutor.mainThread()) { (response) -> Any? in
                    if let error = response.error {
                        debugPrint("Failed to create user: \(error.localizedDescription)")
                    }
                    else if let user = response.result?.user {
                        self.performSegue(withIdentifier: SHOW_VERIFY_ACCOUNT, sender: user)
                    }
                    return nil
            }
        }
    }
    
    
    @IBAction func alreadyHaveCodeButtonAction() {
        performSegue(withIdentifier: SHOW_VERIFY_ACCOUNT, sender: "")
    }
    
    
    // MARK: - Private Funtions
    
    // Validate email or phone number and password prior to attempting to create a new user
    // TODO:
    // - If signup method is email, validate email.
    // - If signup method is phone number, validate phone number.
    // Valid phone numbers are strings prefixed with '+' and the international code. ex: +14128885555
    private func inputDataIsValid() -> Bool {
        return true
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verifyAccountVC = segue.destination as? VerifyUserVC, let awsUser = sender as? AWSCognitoIdentityUser {
            verifyAccountVC.awsUser = awsUser
            verifyAccountVC.signInCredentials = signInCredentials
        }
    }
}
