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

class EditProfileVC: UIViewController, UITextViewDelegate {

    
    enum EditImageType {
        case profile
        case background
    }
    
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    var user: User!
    var imagePicker: UIImagePickerController!
    var editImageType: EditImageType!
    var profileImage: UIImage?
    var backgroundImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureImagePicker()
    }
    
    
    func initData(user: User) {
        self.user = user
    }
    
    
    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction() {
        updateUser()
        
//        guard let image = profileImage, let imageData = UIImageJPEGRepresentation(image, 0.5) else {
//            debugPrint("Could not convert image to jpeg data")
//            return
//        }
//
//        // Remove
//        print("There were \(imageData.count) bytes")
//        let bcf = ByteCountFormatter()
//        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
//        bcf.countStyle = .file
//        let string = bcf.string(fromByteCount: Int64(imageData.count))
//        print("formatted result: \(string)")
//        // Remove
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
    
    
    private func configureImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    
    private func updateUser() {
        
        guard let profileImage = profileImage else {
            debugPrint("Profile image is nil")
            return
        }
        
        S3BucketService.instance.uploadImage(image: profileImage, bucketType: .profileImage)
        
//        UserService.instance.updateUser(user: user) { (success) in
//            if success {
//                debugPrint("Successfully updated user")
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//            else {
//                debugPrint("Failed to updated user")
//            }
//        }
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

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            switch editImageType! {
            case .profile:
                self.profileImage = image
                self.profileImageView.image = image
            case .background:
                self.backgroundImage = image
                self.backgroundImageView.image = image
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
