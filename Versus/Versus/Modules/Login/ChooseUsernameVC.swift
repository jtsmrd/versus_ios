//
//  ChooseUsernameVC.swift
//  Versus
//
// Allows the user to choose a username that isn't already being used.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class ChooseUsernameVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameAvailabilityLabel: UILabel!
    @IBOutlet weak var signupButton: RoundButton!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    // MARK: - Actions
    
    // Abort the signup process and transition back to LandingVC.
    // TODO:
    // - Display confirmation alert.
    // - Delete data already created for user.
    @IBAction func cancelButtonAction() {
        performSegue(withIdentifier: UNWIND_LANDING, sender: nil)
    }
    
    
    // Completes the signup process and transitions to [follow celebrities view]
    // TODO:
    // - Create user record with chosen username.
    // - Create [follow celebrities view]
    @IBAction func signupButtonAction() {
        
    }
}
