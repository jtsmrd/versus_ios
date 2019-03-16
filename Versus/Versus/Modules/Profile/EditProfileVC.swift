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

protocol EditProfileVCDelegate {
    func profileUpdated()
}

class EditProfileVC: UIViewController {

    
    enum EditImageType {
        case profile
        case background
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var bioContainerView: BorderView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private let accountService = AccountService.instance
    private let userService = UserService.instance
    private let s3BucketService = S3BucketService.instance
    
    private var imagePicker: UIImagePickerController!
    private var editImageType: EditImageType!
    private var profileImage: UIImage?
    private var backgroundImage: UIImage?
    private var keyboardToolbar: KeyboardToolbar!
    private var keyboardWillShowObserver: NSObjectProtocol!
    private var keyboardWillHideObserver: NSObjectProtocol!
    private var visibleRect: CGRect = .zero
    
    var delegate: EditProfileVCDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        visibleRect = view.frame
        configureView()
        configureImagePicker()
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    @objc func keyboardDidShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(
            forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        let contentInsets = UIEdgeInsets.init(
            top: 0.0,
            left: 0.0,
            bottom: keyboardHeight,
            right: 0.0
        )
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        visibleRect.size.height -= keyboardHeight
        
        scrollToFirstResponderIfNeeded()
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        
        visibleRect = view.frame
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
        
        usernameTextField.text = CurrentAccount.user.username
        displayNameTextField.text = CurrentAccount.user.name
        bioTextView.text = CurrentAccount.user.bio
        emailTextField.text = CurrentAccount.user.email
        
        let profileImageId = CurrentAccount.user.profileImage
        if !profileImageId.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: profileImageId,
                imageType: .regular
            ) { [weak self] (image, customError) in
                
                if let customError = customError {
                    self?.displayError(error: customError)
                    return
                }
                
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
        
        let backgroundImage = CurrentAccount.user.backgroundImage        
        if !backgroundImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: backgroundImage,
                imageType: .background
            ) { [weak self] (image, customError) in
                
                if let customError = customError {
                    self?.displayError(error: customError)
                    return
                }
                
                DispatchQueue.main.async {
                    self?.backgroundImageView.image = image
                }
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
            CurrentAccount.user.name = displayName
        }
        
        if let bio = bioTextView.text, !bio.isEmpty {
            CurrentAccount.user.bio = bio
        }
        
        
        userService.updateProfile(
            user: CurrentAccount.user,
            profileImage: profileImage,
            backgroundImage: backgroundImage
        ) { [weak self] (user, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let user = user else {
                    self?.displayMessage(message: "Unable to update account")
                    return
                }
                
                CurrentAccount.setUser(user: user)
                self?.delegate?.profileUpdated()
                
                self?.dismiss(
                    animated: true,
                    completion: nil
                )
            }
        }
    }
    
    
    private func editImage() {
        
        let imageSourceAlert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        imageSourceAlert.addAction(
            UIAlertAction(
                title: "Camera",
                style: .default,
                handler: { (action) in
                    self.presentImagePicker(
                        sourceType: .camera
                    )
                }
            )
        )
        
        imageSourceAlert.addAction(
            UIAlertAction(
                title: "Photo Library",
                style: .default,
                handler: { (action) in
                    self.presentImagePicker(
                        sourceType: .photoLibrary
                    )
                }
            )
        )
        
        imageSourceAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        present(
            imageSourceAlert,
            animated: true,
            completion: nil
        )
    }
    
    
    private func presentImagePicker(
        sourceType: UIImagePickerController.SourceType
    ) {
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        
        present(
            imagePicker,
            animated: true,
            completion: nil
        )
    }
    
    
    private func cropImage(
        image: UIImage,
        cropImageType: CropImageType
    ) {
        
        let editImageStoryboard = UIStoryboard(
            name: EDIT_IMAGE,
            bundle: nil
        )
        
        let editImageVC = editImageStoryboard.instantiateInitialViewController()
        
        if let editImageVC = editImageVC as? EditImageVC {
            
            editImageVC.initData(
                imageToCrop: image,
                cropImageType: cropImageType,
                delegate: self
            )
            present(
                editImageVC,
                animated: true,
                completion: nil
            )
        }
    }
    
    
    /**
     Used to scroll to the active first responder if it's covered by the
     keyboard.
    */
    private func scrollToFirstResponderIfNeeded() {
        
        var activeFirstResponderFrame: CGRect = activeFirstResponder.frame
        
        // We have to convert the view's frame if it's superview isn't
        // the contentView.
        if activeFirstResponder.superview != contentView {
            
            if activeFirstResponder.superview == bioContainerView {
                activeFirstResponderFrame = bioContainerView.convert(
                    activeFirstResponder.frame,
                    to: nil
                )
            }
        }
        
        // If the firstResponder isn't visible, scroll.
        if !visibleRect.contains(activeFirstResponderFrame.origin) {
            
            scrollView.scrollRectToVisible(
                activeFirstResponderFrame,
                animated: true
            )
        }
    }
}

extension EditProfileVC: UITextViewDelegate {
    
    
    func textViewShouldBeginEditing(
        _ textView: UITextView
    ) -> Bool {
        textView.inputAccessoryView = keyboardToolbar
        return true
    }
    
    
    func textViewDidBeginEditing(
        _ textView: UITextView
    ) {
        activeFirstResponder = textView
        scrollToFirstResponderIfNeeded()
    }
    
    
    func textViewDidChange(
        _ textView: UITextView
    ) {
//        CurrentUser.bio = textView.text
    }
}

extension EditProfileVC: UITextFieldDelegate {
    
    
    func textFieldShouldBeginEditing(
        _ textField: UITextField
    ) -> Bool {
        textField.inputAccessoryView = keyboardToolbar
        return true
    }
    
    
    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        activeFirstResponder = textField
        scrollToFirstResponderIfNeeded()
    }
}

extension EditProfileVC:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(
            animated: true,
            completion: nil
        )
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            switch editImageType! {
            case .profile:
                cropImage(
                    image: image,
                    cropImageType: .circle
                )
            case .background:
                cropImage(
                    image: image,
                    cropImageType: .landscape
                )
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {
        picker.dismiss(
            animated: true,
            completion: nil
        )
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
