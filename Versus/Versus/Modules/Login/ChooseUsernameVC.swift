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
    @IBOutlet weak var continueButton: RoundButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        guard let username = usernameTextField.text, !username.isEmpty else {
            
            // Display error
            
            return false
        }
        
        return true
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
