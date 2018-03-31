//
//  EmailSignupVC.swift
//  Versus
//
// Creates a new identity (in User Pool) via email.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class EmailSignupVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var continueButton: RoundButton!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    // MARK: - Actions
    
    // Transitions back to LandingVC
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // Created a new identity (in User Pool) via email then transitions to ChooseUsernameVC.
    // TODO:
    // - Authenticate using AWS Cognito via email.
    @IBAction func continueButtonAction() {
        performSegue(withIdentifier: SHOW_CHOOSE_USERNAME, sender: nil)
    }
}
