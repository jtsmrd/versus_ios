//
//  LoginVC.swift
//  Versus
//
// Allows user to log in via mail & password, Facebook, or Google.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let accountService = AccountService.instance
    private let userService = UserService.instance
    
    var keyboardToolbar: KeyboardToolbar!
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardToolbar = KeyboardToolbar(includeNavigation: true)
        
        if let lastSignedInUsername = CurrentAccount.lastSignedInUsername {
            usernameTextField.text = lastSignedInUsername
            passwordTextField.becomeFirstResponder()
        }
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
        login()
    }
    
    
    // MARK: - Private Funtions
    
    private func login() {
        
        guard inputDataIsValid() else { return }
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        accountService.login(
            username: username,
            password: password
        ) { [weak self] (account, errorMessage) in
            
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let account = account else {
                    self?.displayMessage(message: "Failed to load account")
                    return
                }
                
                CurrentAccount.setAccount(account: account)
                self?.loadFollowedUserIds()
                
                self?.performSegue(withIdentifier: SHOW_MAIN_STORYBOARD, sender: nil)
            }
        }
    }
    
    private func inputDataIsValid() -> Bool {
        
        guard let username = usernameTextField.text, !username.isEmpty else {
            displayMessage(message: "Please enter a valid email")
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(message: "Please enter a valid password")
            return false
        }
        
        return true
    }
    
    
    private func loadFollowedUserIds() {
        
        userService.loadFollowedUserIds(
            userId: CurrentAccount.user.id
        ) { (followedUserIds, errorMessage) in
            
            guard let followedUserIds = followedUserIds else {
                return
            }
            
            CurrentAccount.setFollowedUserIds(ids: followedUserIds)
        }
    }
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
}
