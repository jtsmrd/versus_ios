//
//  EditProfileVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class EditProfileVC: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    
    func initData(user: User) {
        self.user = user
    }
    
    
    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction() {
        updateUser()
    }
    
    @IBAction func editBackgroundImageAction() {
        
    }
    
    @IBAction func editProfileButtonAction() {
        
    }
    
    
    private func configureView() {
        usernameTextField.text = user._username
        bioTextView.text = user._bio
        
        // Get and display the users' email
        let currentUser = AWSCognitoIdentityUserPool.default().currentUser()
        currentUser?.getDetails().continueWith(executor: AWSExecutor.mainThread(), block: { (response) -> Any? in
            if let error = response.error {
                debugPrint("Error getting user details: \(error.localizedDescription)")
            }
            else if let result = response.result {
                if let attributes = result.userAttributes {
                    for attribute in attributes {
                        if let attributeName = attribute.name, attributeName == "email" {
                            if let email = attribute.value {
                                self.emailTextField.text = email
                            }
                        }
                    }
                }
            }
            
            return nil
        })
    }
    
    private func updateUser() {
        UserService.instance.updateUser(user: user) { (success) in
            if success {
                debugPrint("Successfully updated user")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                debugPrint("Failed to updated user")
            }
        }
    }
    
    
    // MARK: - UITextViewDelegate Functions
    
    func textViewDidChange(_ textView: UITextView) {
        user._bio = textView.text
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
