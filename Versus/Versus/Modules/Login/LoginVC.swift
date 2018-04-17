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
import AWSUserPoolsSignIn

class LoginVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameOrEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var signInCredentials: SignInCredentials!
    
    
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
        signIn()
    }
    
    
    // MARK: - Private Funtions
    
    private func signIn() {
        
        guard inputDataIsValid() else { return }
        
        let username = usernameOrEmailTextField.text!
        let password = passwordTextField.text!
        
        signInCredentials = SignInCredentials(username: username, password: password)
        appDelegate.prepareForSignIn(signInCredentials: signInCredentials)
        
        let signInProvider: AWSSignInProvider = AWSCognitoUserPoolsSignInProvider.sharedInstance()
        AWSSignInManager.sharedInstance().login(
            signInProviderKey: signInProvider.identityProviderName
        ) { (result, error) in
            if let error = error {
                debugPrint("Failed to login: \(error.localizedDescription)")
                return
            }
            else {
                self.loadCurrentUser()
            }
        }
    }
    
    private func loadCurrentUser() {
        UserService.instance.loadUser(
            userPoolUserId: CurrentUser.userPoolUserId
        ) { (awsUser, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if let awsUser = awsUser {
                    CurrentUser.user = User(awsUser: awsUser)
                    self.performSegue(withIdentifier: SHOW_MAIN_STORYBOARD, sender: nil)
                }
                else {
                    // User closed app without selecting a usename, which creates a user
                    self.performSegue(withIdentifier: SHOW_CHOOSE_USERNAME, sender: nil)
                }
            }
        }
    }
    
    private func inputDataIsValid() -> Bool {
        
        guard let username = usernameOrEmailTextField.text, !username.isEmpty else {
            
            // Display error
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            
            // Display error
            return false
        }
        
        return true
    }
}
