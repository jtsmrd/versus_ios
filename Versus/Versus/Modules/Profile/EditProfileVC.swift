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
    @IBOutlet weak var displayNameTextField: UITextField!
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
        
        usernameTextField.text = user.awsUser._username
        displayNameTextField.text = user.awsUser._displayName
        bioTextView.text = user.awsUser._bio
        profileImageView.image = CurrentUser.user.profileImage
        backgroundImageView.image = CurrentUser.user.profileBackgroundImage
        
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
        
        // Update images
        let updateDispatchGroup = DispatchGroup()
        
        var profileImageUploadSuccess = true
        var profileImageSmallUploadSuccess = true
        var profileBackgroundImageUploadSuccess = true
        
        if let image = profileImage {
            
            updateDispatchGroup.enter()
                UserService.instance.uploadImage(
                image: image,
                bucketType: .profileImage
            ) { (imageFilename) in
                profileImageUploadSuccess = imageFilename != nil
                
                //TODO: This will be updated and handled with AWS caching, which will get new if exists
                // Set stored image to nil so newly saved image will be downloaded
                CurrentUser.user.profileImage = nil
                
                updateDispatchGroup.leave()
            }
            
            updateDispatchGroup.enter()
            UserService.instance.uploadImage(
                image: image,
                bucketType: .profileImageSmall
            ) { (imageFilename) in
                profileImageSmallUploadSuccess = imageFilename != nil
                updateDispatchGroup.leave()
            }
        }
        
        if let image = backgroundImage {
            
            updateDispatchGroup.enter()
            UserService.instance.uploadImage(
                image: image,
                bucketType: .profileBackgroundImage
            ) { (imageFilename) in
                profileBackgroundImageUploadSuccess = imageFilename != nil
                
                //TODO: This will be updated and handled with AWS caching, which will get new if exists
                // Set stored image to nil so newly saved image will be downloaded
                CurrentUser.user.profileBackgroundImage = nil
                
                updateDispatchGroup.leave()
            }
        }
        
        updateDispatchGroup.notify(queue: .main) {
            
            // If all applicable image updates are successful, update user
            if profileImageUploadSuccess && profileImageSmallUploadSuccess && profileBackgroundImageUploadSuccess {
                
                self.user.awsUser._displayName = self.displayNameTextField.text
                self.user.awsUser._profileImageUpdateDate = Date().toISO8601String
                self.user.awsUser._profileBackgroundImageUpdateDate = Date().toISO8601String
                
                UserService.instance.updateUser(user: self.user.awsUser) { (success) in
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
                debugPrint("Failed to upload image")
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
    
    
    // MARK: - UITextViewDelegate Functions
    
    func textViewDidChange(_ textView: UITextView) {
        user.awsUser._bio = textView.text
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
