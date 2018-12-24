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
    @IBOutlet weak var passwordRequirementsLabel: UILabel!
    @IBOutlet weak var signupButton: RoundButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    // MARK: - Variables
    
    var signupMethod: SignupMethod = .email
    var signInCredentials: SignInCredentials!
    var keyboardToolbar: KeyboardToolbar!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardToolbar = KeyboardToolbar(includeNavigation: true)
        
        switch signupMethod {
        case .email:
            emailPhoneNumberTextField.placeholder = "Email"
            emailPhoneNumberTextField.keyboardType = .emailAddress
        case .phoneNumber:
            emailPhoneNumberTextField.placeholder = "Phone number"
            emailPhoneNumberTextField.keyboardType = .phonePad
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
        
        // If the user exits the app before signing in, we need the username and password when signing in
        CurrentUser.setSignInCredentials(signInCredentials: signInCredentials)
        
        AccountService.instance.signUp(
            username: username,
            password: password
        ) { (awsUser, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if let _ = awsUser {
                    self.performSegue(withIdentifier: SHOW_VERIFY_USER, sender: nil)
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
        
        switch signupMethod {
        case .email:
            guard emailPhoneNumber.isValidEmail else {
                displayMessage(message: "Provide a valid email")
                return false
            }
        case .phoneNumber:
            guard emailPhoneNumber.isValidPhoneNumber else {
                displayMessage(message: "Provide a valid phone number")
                return false
            }
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(message: "Provide a valid password")
            return false
        }
        
        guard password.isValidPassword else {
            displayMessage(message: "Provide a valid password")
            return false
        }
        
        return true
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension SignupVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
}
