//
//  EditProfileVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn
import MobileCoreServices

class EditProfileVC: UIViewController {

    
    enum EditImageType {
        case profile
        case background
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    var imagePicker: UIImagePickerController!
    var editImageType: EditImageType!
    var profileImage: UIImage?
    var backgroundImage: UIImage?
    var keyboardToolbar: KeyboardToolbar!
    var keyboardWillShowObserver: NSObjectProtocol!
    var keyboardWillHideObserver: NSObjectProtocol!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureImagePicker()
        
        keyboardToolbar = KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50), includeNavigation: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let currentTextFieldOrigin = activeFirstResponder.frame.origin
        let currentTextFieldHeight = activeFirstResponder.frame.size.height
        var visibleRect = view.frame
        visibleRect.size.height -= keyboardHeight
        let scrollPoint = CGPoint(x: 0.0, y: currentTextFieldOrigin.y - visibleRect.size.height + (currentTextFieldHeight + 100))
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction() {
        updateUser()
    }
    
    @IBAction func editBackgroundImageAction() {
        editImageType = .background
        editImage()
    }
    
    @IBAction func editProfileButtonAction() {
        editImageType = .profile
        editImage()
    }
    
    
    private func configureView() {
        
        usernameTextField.text = CurrentUser.username
        displayNameTextField.text = CurrentUser.displayName
        bioTextView.text = CurrentUser.bio
        if let profileImage = CurrentUser.profileImage {
            profileImageView.image = profileImage
        }
        if let backgroundImage = CurrentUser.profileBackgroundImage {
            backgroundImageView.image = backgroundImage
        }
        
        AccountService.instance.getEmail { (email) in
            DispatchQueue.main.async {
                self.emailTextField.text = email
            }
        }
    }
    
    private func configureImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    
    private func updateUser() {
        if let displayName = displayNameTextField.text, !displayName.isEmpty {
            CurrentUser.displayName = displayName
            CurrentUser.searchDisplayName = displayName.lowercased()
        }
        if let username = usernameTextField.text, !username.isEmpty {
            CurrentUser.username = username
            CurrentUser.searchUsername = username.lowercased()
        }
        if let bio = bioTextView.text, !bio.isEmpty {
            CurrentUser.bio = bio
        }
        
        CurrentUser.updateProfile(
            profileImage: profileImage,
            backgroundImage: backgroundImage
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    private func editImage() {
        let imageSourceAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imageSourceAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.presentImagePicker(sourceType: .camera)
        }))
        
        imageSourceAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        
        imageSourceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        present(imageSourceAlert, animated: true, completion: nil)
    }
    
    
    private func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    private func cropImage(image: UIImage, cropImageType: CropImageType) {
        let editImageVC = UIStoryboard(name: EDIT_IMAGE, bundle: nil).instantiateInitialViewController() as! EditImageVC
        editImageVC.initData(imageToCrop: image, cropImageType: cropImageType, delegate: self)
        present(editImageVC, animated: true, completion: nil)
    }
}

extension EditProfileVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeFirstResponder = textView
    }
    
    func textViewDidChange(_ textView: UITextView) {
        CurrentUser.bio = textView.text
    }
}

extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeFirstResponder = textField
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            switch editImageType! {
            case .profile:
                cropImage(image: image, cropImageType: .circle)
            case .background:
                cropImage(image: image, cropImageType: .landscape)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension EditProfileVC: EditImageVCDelegate {
    
    func imageCropped(image: UIImage) {
        switch editImageType! {
        case .profile:
            profileImage = image
            profileImageView.image = image
        case .background:
            backgroundImage = image
            backgroundImageView.image = image
        }
    }
}
