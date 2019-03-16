//
//  ChangePasswordVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ChangePasswordVC: UIViewController {

    private let accountService = AccountService.instance
    
    @IBOutlet weak var verificationTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var changePasswordButton: RoundButton!
    @IBOutlet weak var cancelButton: RoundButton!
    
    var keyboardToolbar: KeyboardToolbar!
    var user: AWSCognitoIdentityUser!
    
    
    /**
 
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardToolbar = KeyboardToolbar(includeNavigation: true)
    }

    
    /**
     
     */
    func initData(user: AWSCognitoIdentityUser) {
        self.user = user
    }
    
    
    /**
     
     */
    @IBAction func changePasswordButtonAction() {
        
        guard let password = newPasswordTextField.text, let confirmPassword = confirmPasswordTextField.text else {
            displayMessage(message: "Enter your new password and confirm")
            return
        }
        
        guard password == confirmPassword else {
            displayMessage(message: "Passwords do not match")
            return
        }
        
        guard let verificationCode = verificationTextField.text else {
            displayMessage(message: "Enter your verification code")
            return
        }
        
//        AccountService.instance.confirmPasswordChange(
//            user: user,
//            verificationCode: verificationCode,
//            password: password
//        ) { (success, customError) in
//            DispatchQueue.main.async {
//                if let customError = customError {
//                    self.displayError(error: customError)
//                }
//                else {
//                    self.displaySuccessMessage()
//                }
//            }
//        }
    }
    
    
    /**
     
     */
    @IBAction func cancelButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    /**
     
     */
    private func displaySuccessMessage() {
        let successAlert = UIAlertController(
            title: "Password Changed",
            message: "Log in with your new password",
            preferredStyle: .alert
        )
        successAlert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default,
                handler: { (action) in
                    self.performSegue(withIdentifier: UNWIND_TO_LANDING, sender: nil)
                }
            )
        )
        present(successAlert, animated: true, completion: nil)
    }
}

extension ChangePasswordVC: UITextFieldDelegate {
    
    
    /**
     
     */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
}
