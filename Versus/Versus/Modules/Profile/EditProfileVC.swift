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
//
//        print("There were \(imageData.count) bytes")
//        let bcf = ByteCountFormatter()
//        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
//        bcf.countStyle = .file
//        let string = bcf.string(fromByteCount: Int64(imageData.count))
//        print("formatted result: \(string)")
//
//
//        let resizedImage = resizeProfileImage(image: image, newWidth: 200.0)
//        if let resizedImage = resizedImage, let resizedData = UIImageJPEGRepresentation(resizedImage, 1.0) {
//
//            print("Resized: There were \(resizedData.count) bytes")
//            let bcf = ByteCountFormatter()
//            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
//            bcf.countStyle = .file
//            let string = bcf.string(fromByteCount: Int64(resizedData.count))
//            print("Resized: formatted result: \(string)")
//        }
    }
    
    private func resizeProfileImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func resizeProfileBackgroundImage(image: UIImage, newHeight: CGFloat) -> UIImage? {
        
        let scale: CGFloat = 6/25
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
        setUserEmail()
        
        // Get profile images
        if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
            
            if let _ = user._profileImageUpdateDate {
                S3BucketService.instance.downloadImage(imageName: username, bucketType: .profileImage) { (image, error) in
                    if let error = error {
                        debugPrint("Error downloading profile image in edit profile: \(error.localizedDescription)")
                    }
                    else if let image = image {
                        DispatchQueue.main.async {
                            self.profileImageView.image = image
                        }
                    }
                }
            }
            
            if let _ = user._profileBackgroundImageUpdateDate {
                S3BucketService.instance.downloadImage(imageName: username, bucketType: .profileBackgroundImage) { (image, error) in
                    if let error = error {
                        debugPrint("Error downloading profile image in edit profile: \(error.localizedDescription)")
                    }
                    else if let image = image {
                        DispatchQueue.main.async {
                            self.backgroundImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    private func setUserEmail() {
        
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
        
        var errorMessage = ""
        let updateDispatchGroup = DispatchGroup()
        
        if let profileImage = profileImage, let resizedProfileImage = resizeProfileImage(image: profileImage, newWidth: 300.0) {
            
            updateDispatchGroup.enter()
            S3BucketService.instance.uploadImage(image: resizedProfileImage, bucketType: .profileImage) { (success) in
                if success {
                    self.user._profileImageUpdateDate = String(Date().timeIntervalSince1970)
                }
                else {
                    debugPrint("Failed to upload image in edit profile")
                    errorMessage = "Unable to upload profile image."
                }
                updateDispatchGroup.leave()
            }
        }
        
        
        if let profileBackgroundImage = backgroundImage, let resizedProfileBackgroundImage = resizeProfileImage(image: profileBackgroundImage, newWidth: 600.0) {
            
            updateDispatchGroup.enter()
            S3BucketService.instance.uploadImage(image: resizedProfileBackgroundImage, bucketType: .profileBackgroundImage) { (success) in
                if success {
                    self.user._profileBackgroundImageUpdateDate = String(Date().timeIntervalSince1970)
                }
                else {
                    debugPrint("Failed to upload background image in edit profile")
                    errorMessage = "Unable to upload background profile image."
                }
                updateDispatchGroup.leave()
            }
        }
        
        
        updateDispatchGroup.notify(queue: .main) {
            
            if errorMessage.isEmpty {
                
                UserService.instance.updateUser(user: self.user) { (success) in
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
            else {
                debugPrint(errorMessage)
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
