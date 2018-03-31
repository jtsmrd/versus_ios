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

class SignupVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var emailPhoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: RoundButton!
    
    
    // MARK: - Variables
    
    var signupMethod: SignupMethod = .email
    
    
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
    
    
    // Created a new identity (in User Pool) via email or phone then transitions to VerifyAccountVC.
    // TODO:
    // - Authenticate using AWS Cognito via email or phone.
    @IBAction func signupButtonAction() {
        
        guard let emailPhoneNumber = emailPhoneNumberTextField.text, !emailPhoneNumber.isEmpty else {
            // Display error
            return
        }
        
        if inputDataIsValid() {
            performSegue(withIdentifier: SHOW_VERIFY_ACCOUNT, sender: nil)
        }
    }
    
    
    @IBAction func alreadyHaveCodeButtonAction() {
        performSegue(withIdentifier: SHOW_VERIFY_ACCOUNT, sender: "")
    }
    
    
    // MARK: - Private Funtions
    
    private func inputDataIsValid() -> Bool {
        return true
    }
}
