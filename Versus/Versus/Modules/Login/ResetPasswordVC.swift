//
//  ResetPasswordVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ResetPasswordVC: UIViewController {

    private let accountService = AccountService.instance
    private let cognito = AWSCognitoIdentityUserPool.default()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: RoundButton!
    
    var keyboardToolbar: KeyboardToolbar!
    var user: AWSCognitoIdentityUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardToolbar = KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50), includeNavigation: false)
    }

    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func resetPasswordButtonAction() {
        
        guard let email = emailTextField.text else {
            displayMessage(message: "Enter a valid email")
            return
        }
        
        user = cognito.getUser(email)
        accountService.resetPassword(
            user: user
        ) { (successMessage, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else if let message = successMessage {
                    self.displaySuccessMessage(message: message)
                }
            }
        }
    }
    
    private func displaySuccessMessage(message: String) {
        let successAlert = UIAlertController(
            title: "Verification Sent",
            message: message,
            preferredStyle: .alert
        )
        successAlert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default,
                handler: { (action) in
                    self.performSegue(withIdentifier: CHANGE_PASSWORD_VC, sender: nil)
                }
            )
        )
        present(successAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let changePasswordVC = segue.destination as? ChangePasswordVC {
            changePasswordVC.initData(user: user)
        }
    }
}

extension ResetPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
}
