//
//  LandingVC.swift
//  Versus
//
// Allows user to sign up or log in to their account.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum SignupMethod {
    case email
    case phoneNumber
}

class LandingVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var termsPrivacyPolicyLabel: UILabel!
    
    
    // MARK: - Variables
    
    var signupMethodsAlert: UIAlertController!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSignupMethods()
    }
    
    
    // MARK: - Actions
    
    // Displays an action sheet with available sign in methods.
    @IBAction func signupButtonAction() {
        present(signupMethodsAlert, animated: true, completion: nil)
    }
    
    
    // Transition to LoginVC.
    @IBAction func loginButtonAction() {
        performSegue(withIdentifier: SHOW_LOGIN, sender: nil)
    }
    
    
    // Unwind segue used when user cancels from ChooseUsernameVC
    @IBAction func unwindFromSignup(segue: UIStoryboardSegue) { }
    
    
    // MARK: - Private Funtions
    
    // Configure action sheet with available sign up methods
    // TODO:
    // - Phone number authentication
    // - Facebook authentication
    // - Google authentication
    // - Email authentication
    // - UI
    private func configureSignupMethods() {
        
        signupMethodsAlert = UIAlertController(title: "Sign up with", message: nil, preferredStyle: .actionSheet)
        
        let phoneNumberAction = UIAlertAction(title: "Phone Number", style: .default) { (action) in
            self.performSegue(withIdentifier: SHOW_SIGNUP, sender: SignupMethod.phoneNumber)
        }
        signupMethodsAlert.addAction(phoneNumberAction)
        
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .default) { (action) in
            
        }
        signupMethodsAlert.addAction(facebookAction)
        
        
        let googleAction = UIAlertAction(title: "Google", style: .default) { (action) in
            
        }
        signupMethodsAlert.addAction(googleAction)
        
        
        let emailAction = UIAlertAction(title: "Email", style: .default) { (action) in
            self.performSegue(withIdentifier: SHOW_SIGNUP, sender: SignupMethod.email)
        }
        signupMethodsAlert.addAction(emailAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        signupMethodsAlert.addAction(cancelAction)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let emailPhoneSignupVC = segue.destination as? SignupVC, let signupMethod = sender as? SignupMethod {
            emailPhoneSignupVC.initData(signupMethod: signupMethod)
        }
    }
}

