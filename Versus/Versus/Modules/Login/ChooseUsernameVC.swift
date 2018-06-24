//
//  ChooseUsernameVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/7/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ChooseUsernameVC: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var usernameExistsLabel: UILabel!
    @IBOutlet weak var continueButton: RoundButton!
    
    var usernameAvailable = false
    var keyboardToolbar: KeyboardToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameExistsLabel.isHidden = true
        
        keyboardToolbar = KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50), includeNavigation: false)
    }
    
    
    @IBAction func cancelButtonAction() {
        AccountService.instance.signOut { (success) in
            if success {
                DispatchQueue.main.async {
                    if let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = loginVC
                        (UIApplication.shared.delegate as! AppDelegate).window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    
    @IBAction func continueButtonAction() {
        guard inputDataIsValid() else { return }
        let username = usernameTextField.text!
        createUser(username: username)
    }    
    
    
    private func createUser(username: String) {
        
        UserService.instance.createUser(username: username) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: SHOW_FOLLOW_SUGGESTIONS, sender: nil)
                }
            }
            else {
                debugPrint("Failed to create user!!!")
            }
        }
    }
    
    private func inputDataIsValid() -> Bool {
        
        guard usernameAvailable else { return false }
        
        guard let username = usernameTextField.text,
            !username.isEmpty,
            username.count > 4,
            username.count < 21 else {
            
            return false
        }
        
        return true
    }
    
    private func checkUsernameAvailability(username: String) {
        
        AccountService.instance.checkAvailabilityOfUsername(username) { (isAvailable) in
            DispatchQueue.main.async {
                if isAvailable {
                    self.usernameAvailable = true
                    self.usernameExistsLabel.isHidden = true
                    self.usernameTextField.layer.borderColor = UIColor.green.cgColor
                }
                else {
                    self.usernameAvailable = false
                    self.usernameExistsLabel.isHidden = false
                    self.usernameTextField.layer.borderColor = UIColor.red.cgColor
                }
            }
        }
    }
}

extension ChooseUsernameVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let existingText = textField.text, existingText.count >= 4 else {
            usernameInfoLabel.textColor = UIColor.red
            return true
        }
        
        usernameInfoLabel.textColor = UIColor.green
        
        if string != "" {
            
            if existingText.count == 20 {
                usernameInfoLabel.textColor = UIColor.red
            }
            else {
                checkUsernameAvailability(username: existingText + string)
            }
        }
        else {
            
            if existingText.count == 5 {
                usernameInfoLabel.textColor = UIColor.red
            }
            else {
                checkUsernameAvailability(username: String(existingText.prefix(upTo: existingText.endIndex)))
            }
        }
        return true
    }
}
