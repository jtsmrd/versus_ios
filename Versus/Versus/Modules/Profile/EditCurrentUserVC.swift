//
//  EditCurrentUserVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

protocol EditCurrentUserVCDelegate {
    func userUpdated()
}

class EditCurrentUserVC: UIViewController {

    
    enum EditImageType {
        case profile
        case background
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var bioView: BorderView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private let accountService = AccountService.instance
    private let userService = UserService.instance
    private let s3BucketService = S3BucketService.instance
    private let notificationCenter = NotificationCenter.default
    
    private var user: User!
    private var delegate: EditCurrentUserVCDelegate!
    private var imagePicker: UIImagePickerController!
    private var editImageType: EditImageType!
    private var profileImage: UIImage?
    private var backgroundImage: UIImage?
    private var keyboardToolbar: KeyboardToolbar!
    private var keyboardWillShowObserver: NSObjectProtocol!
    private var keyboardWillHideObserver: NSObjectProtocol!
    private var visibleRect: CGRect = .zero
    
    
    
    
    init(user: User, delegate: EditCurrentUserVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        visibleRect = view.frame
        configureView()
        configureImagePicker()
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationCenter.removeObserver(
            self,
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        notificationCenter.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    
    
    @objc func keyboardDidShow(notification: NSNotification) {
        
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardFrame = userInfo.value(
            forKey: UIResponder.keyboardFrameEndUserInfoKey
        ) as! NSValue
        
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
    
    
    @IBAction func saveButtonAction() {
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
        
        usernameTextField.text = user.username
        displayNameTextField.text = user.name
        bioTextView.text = user.bio
        emailTextField.text = user.email
        
        downloadProfileImage()
        downloadBackgroundImage()
    }
    
    
    private func downloadProfileImage() {
        
        if !user.profileImageId.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.profileImageId,
                imageType: .regular
            ) { [weak self] (image, customError) in
                
                if customError != nil {
                    self?.displayMessage(
                        message: "Unable to download profile image"
                    )
                    return
                }
                
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
    }
    
    
    private func downloadBackgroundImage() {
        
        if !user.backgroundImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.backgroundImage,
                imageType: .background
            ) { [weak self] (image, customError) in
                
                if customError != nil {
                    self?.displayMessage(
                        message: "Unable to download background image"
                    )
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
            user.name = displayName
        }
        
        if let bio = bioTextView.text, !bio.isEmpty {
            user.bio = bio
        }
        
        
        userService.updateProfile(
            user: user,
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
                self?.delegate.userUpdated()
                
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
            
            editImageVC.modalPresentationStyle = .overFullScreen
            
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
            
            if activeFirstResponder.superview == bioView {
                activeFirstResponderFrame = bioView.convert(
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




extension EditCurrentUserVC: UITextViewDelegate {
    
    
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
}




extension EditCurrentUserVC: UITextFieldDelegate {
    
    
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




extension EditCurrentUserVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
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
        if let image = info[
            convertFromUIImagePickerControllerInfoKey(
                UIImagePickerController.InfoKey.originalImage
            )
        ] as? UIImage {
            
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




extension EditCurrentUserVC: EditImageVCDelegate {
    
    
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
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(
    _ input: [UIImagePickerController.InfoKey: Any]
) -> [String: Any] {
    
    return Dictionary(
        uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)}
    )
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(
    _ input: UIImagePickerController.InfoKey
) -> String {
    
    return input.rawValue
}
