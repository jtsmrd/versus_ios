//
//  LoginVC.swift
//  Versus
//
// Allows user to log in via username/ email & password, Facebook, or Google.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameOrEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    // MARK: - Actions
    
    // Transition back to LandingVC
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // Authenticate user via username/ email & password
    // TODO:
    // - Authenticate user via username/ email & password
    @IBAction func loginButtonAction() {
        
    }
}
