//
//  SignupVC.swift
//  Versus
//
// Creates a new User.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class SignupVC: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypedPasswordTextField: UITextField!
    @IBOutlet weak var validationMessageLabel: UILabel!
    @IBOutlet weak var signupButton: RoundButton!
    
    
    
    // MARK: - Constants
    
    private let accountService = AccountService.instance
    
    
    
    // MARK: - Variables
    
    private var keyboardToolbar: KeyboardToolbar!
    private var inputValid: Bool = false {
        didSet {
            validationMessageLabel.isHidden = inputValid
        }
    }
    private var usernameAvailable: Bool = false {
        didSet {
            validationMessageLabel.isHidden = usernameAvailable
        }
    }
    
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardToolbar = KeyboardToolbar(includeNavigation: true)
    }

    
    
    // MARK: - Actions
    
    // Transitions back to LandingVC
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    /// Validate input and create a new User.
    @IBAction func signupButtonAction() {
        
        guard inputDataIsValid() else { return }
        
        let name = fullNameTextField.text!
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let retypedPassword = retypedPasswordTextField.text!
        
        if CurrentAccount.user.id == -1 {
            
            createUserAccount(
                name: name,
                username: username,
                email: email,
                password: password,
                retypedPassword: retypedPassword
            )
        }
        else {
            
            loginUser(
                username: username,
                password: password
            )
        }
    }
    
    
    
    // MARK: - Private Funtions
    
    
    /// Validate input for creating a new user.
    ///
    /// - Returns: true | false
    private func inputDataIsValid() -> Bool {
        
        guard let name = fullNameTextField.text, !name.isEmpty, name.count > 3 else {
            displayMessage(message: "Please enter your full name")
            return false
        }
        
        guard let username = usernameTextField.text, !username.isEmpty, username.count >= 5, username.count <= 20 else {
            displayMessage(message: "Please enter a username")
            return false
        }
        
        guard usernameAvailable else {
            displayMessage(message: "Please enter a valid username")
            return false
        }
        
        guard let email = emailTextField.text, !email.isEmpty, email.isValidEmail else {
            displayMessage(message: "Please enter a valid email")
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty, password.isValidPassword else {
            displayMessage(message: "Please enter a valid password")
            return false
        }
        
        guard let retypedPassword = retypedPasswordTextField.text, retypedPassword == password else {
            displayMessage(message: "Passwords do not match")
            return false
        }
        
        return true
    }
    
    
    
    private func checkUsernameAvailability(username: String) {
        
        //TODO: Handle search concurrency.
        accountService.checkUsernameAvailability(
            username: username
        ) { [weak self] (available, errorMessage) in
            
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                if !available {
                    self?.validationMessageLabel.text = "Username unavailable"
                }
                self?.usernameAvailable = available
            }
        }
    }
    
    
    
    private func createUserAccount(
        name: String,
        username: String,
        email: String,
        password: String,
        retypedPassword: String
    ) {
        
        accountService.signUp(
            name: name,
            username: username,
            email: email,
            password: password,
            retypedPassword: retypedPassword
        ) { [weak self] (account, errorMessage) in
            
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let account = account else {
                    self?.displayMessage(message: "Unable to load account")
                    return
                }
                
                CurrentAccount.setAccount(account: account)
                self?.performSegue(withIdentifier: SHOW_FOLLOW_SUGGESTIONS, sender: nil)
            }
        }
    }
    
    
    
    private func loginUser(
        username: String,
        password: String
    ) {
        
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
                    self?.displayMessage(message: "Unable to load account")
                    return
                }
                
                CurrentAccount.setAccount(account: account)
                self?.performSegue(withIdentifier: SHOW_FOLLOW_SUGGESTIONS, sender: nil)
            }
        }
    }
}

extension SignupVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == usernameTextField, let existingText = textField.text {
            
            // Don't attempt to search unless the existing text
            // is >= 4 characters.
            guard existingText.count >= 4 else {
                return true
            }
            
            // Don't search or allow users to enter more than
            // 20 characters for a username.
            guard existingText.count <= 20 else {
                return false
            }
            
            let newText = string
            var usernameText = ""
            
            // If the newText is empty, the last character will be deleted.
            if newText.isEmpty {
                usernameText = String(existingText.prefix(existingText.count - 1))
            }
            else { // Append the new character to the usernameText
                usernameText = existingText + newText
            }
            
            guard usernameText.count >= 5 else {
                return true
            }
            
            checkUsernameAvailability(username: usernameText)
        }
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == fullNameTextField {
            
            guard let name = fullNameTextField.text, !name.isEmpty, name.count > 3 else {
                validationMessageLabel.text = "Please enter a valid name"
                textField.layer.borderColor = UIColor.red.cgColor
                inputValid = false
                return
            }
        }
        else if textField == usernameTextField {
            
            guard let username = usernameTextField.text, !username.isEmpty, username.count > 4 else {
                validationMessageLabel.text = "Please enter a valid username"
                textField.layer.borderColor = UIColor.red.cgColor
                inputValid = false
                return
            }
        }
        else if textField == emailTextField {
            
            guard let email = emailTextField.text, !email.isEmpty, email.isValidEmail else {
                validationMessageLabel.text = "Please enter a valid email"
                textField.layer.borderColor = UIColor.red.cgColor
                inputValid = false
                return
            }
        }
        else if textField == passwordTextField {
            
            guard let password = passwordTextField.text, password.isValidPassword else {
                validationMessageLabel.text = "Please enter a valid password"
                textField.layer.borderColor = UIColor.red.cgColor
                inputValid = false
                return
            }
        }
        else if textField == retypedPasswordTextField {
            
            guard let password = passwordTextField.text else {
                validationMessageLabel.text = "Please enter a valid password"
                textField.layer.borderColor = UIColor.red.cgColor
                inputValid = false
                return
            }
            
            guard let retypedPassword = retypedPasswordTextField.text, retypedPassword == password else {
                validationMessageLabel.text = "Passwords do not match"
                textField.layer.borderColor = UIColor.red.cgColor
                inputValid = false
                return
            }
        }
        
        textField.layer.borderColor = UIColor.green.cgColor
        inputValid = true
    }
}
