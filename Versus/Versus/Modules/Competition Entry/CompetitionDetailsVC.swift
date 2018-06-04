//
//  CompetitionDetailsVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AVKit

class CompetitionDetailsVC: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var selectCategoryView: BorderView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTableView: UITableView!
    
    var competitionImage: UIImage?
    var competitionVideoUrlAsset: AVURLAsset?
    var competitionVideoPreviewImage: UIImage?
    var competitionType: CompetitionType = .image
    var selectedCategory: Category?
    var keyboardToolbar: KeyboardToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardToolbar = KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50), includeNavigation: false)
        
        submitButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        selectCategoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryViewTapped)))
        
        configureView()
    }

    
    func initData(image: UIImage?, videoUrlAsset: AVURLAsset?) {
        competitionImage = image
        competitionVideoUrlAsset = videoUrlAsset
        competitionType = image != nil ? .image : .video
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction() {
        
        guard inputDataIsValid() else { return }
        
        let uploadMediaDispatchGroup = DispatchGroup()
        var errorMessage = ""
        var competitionImageFilename: String?
        var competitionImageSmallFilename: String?
        var competitionVideoFilename: String?
        var competitionVideoPreviewImageFilename: String?
        var competitionVideoPreviewImageSmallFilename: String?
        
        submitButton.isEnabled = false
        
        switch competitionType {
        case .image:
            
            uploadMediaDispatchGroup.enter()
            CompetitionEntryService.instance.uploadCompetitionImage(image: competitionImage!, bucketType: .competitionImage, competitionImageSizeType: .normal) { (imageFilename) in
                if let imageFilename = imageFilename {
                    competitionImageFilename = imageFilename
                }
                else {
                    errorMessage = "Failed to upload competition image"
                }
                uploadMediaDispatchGroup.leave()
            }
            
            uploadMediaDispatchGroup.enter()
            CompetitionEntryService.instance.uploadCompetitionImage(image: competitionImage!, bucketType: .competitionImageSmall, competitionImageSizeType: .small) { (imageFilename) in
                if let imageFilename = imageFilename {
                    competitionImageSmallFilename = imageFilename
                }
                else {
                    errorMessage = "Failed to upload competition image small"
                }
                uploadMediaDispatchGroup.leave()
            }
            
        case .video:
            
            uploadMediaDispatchGroup.enter()
            CompetitionEntryService.instance.uploadCompetitionVideo(videoUrlAsset: competitionVideoUrlAsset!, bucketType: .competitionVideo) { (videoFilename) in
                if let videoFilename = videoFilename {
                    competitionVideoFilename = videoFilename
                }
                else {
                    errorMessage = "Failed to upload competition video"
                }
                uploadMediaDispatchGroup.leave()
            }
            
            uploadMediaDispatchGroup.enter()
            CompetitionEntryService.instance.uploadCompetitionImage(image: competitionVideoPreviewImage!, bucketType: .competitionVideoPreviewImage, competitionImageSizeType: .normal) { (imageFilename) in
                if let imageFilename = imageFilename {
                    competitionVideoPreviewImageFilename = imageFilename
                }
                else {
                    errorMessage = "Failed to upload competition video preview image"
                }
                uploadMediaDispatchGroup.leave()
            }
            
            uploadMediaDispatchGroup.enter()
            CompetitionEntryService.instance.uploadCompetitionImage(image: competitionVideoPreviewImage!, bucketType: .competitionVideoPreviewImageSmall, competitionImageSizeType: .small) { (imageFilename) in
                if let imageFilename = imageFilename {
                    competitionVideoPreviewImageSmallFilename = imageFilename
                }
                else {
                    errorMessage = "Failed to upload competition video preview image small"
                }
                uploadMediaDispatchGroup.leave()
            }
        }
        
        
        uploadMediaDispatchGroup.notify(queue: .main) {
            if errorMessage.isEmpty {
                self.createCompetitionEntry(
                    videoPreviewImageId: competitionVideoPreviewImageFilename,
                    videoPreviewImageSmallId: competitionVideoPreviewImageSmallFilename,
                    videoId: competitionVideoFilename,
                    imageId: competitionImageFilename,
                    imageSmallId: competitionImageSmallFilename,
                    completion: { (success) in
                        DispatchQueue.main.async {
                            if success {
                                self.performSegue(withIdentifier: SHOW_COMPETITION_SUBMITTED, sender: nil)
                            }
                            else {
                                self.displayMessage(message: "Unable to submit competition entry")
                            }
                            self.submitButton.isEnabled = true
                        }
                    }
                )
            }
            else {
                self.submitButton.isEnabled = true
                self.displayMessage(message: errorMessage)
            }
        }
    }
    
    @IBAction func facebookButtonAction() {
        
    }
    
    @IBAction func instagramButtonAction() {
        
    }
    
    @IBAction func twitterButtonAction() {
        
    }
    
    
    @objc func categoryViewTapped() {
        categoryTableView.isHidden = !categoryTableView.isHidden
    }
    
    
    private func configureView() {
        if let category = selectedCategory {
            categoryLabel.text = category.title
            categoryLabel.textColor = UIColor.white
            categoryImageView.image = UIImage(named: category.iconName)
            selectCategoryView.backgroundColor = category.backgroundColor
        }
        else {
            categoryLabel.textColor = UIColor.darkGray
        }
        
        switch competitionType {
        case .image:
            previewImageView.image = competitionImage
        case .video:
            competitionVideoPreviewImage = Utilities.generatePreviewImage(for: competitionVideoUrlAsset!)
            previewImageView.image = competitionVideoPreviewImage
        }
    }
    
    private func inputDataIsValid() -> Bool {
        
        guard let _ = selectedCategory else {
            displayMessage(message: "Select a category")
            return false
        }
        
        switch competitionType {
        case .image:
            guard let _ = competitionImage else {
                displayMessage(message: "Select competition image")
                return false
            }
        case .video:
            guard let _ = competitionVideoUrlAsset else {
                displayMessage(message: "Select competition video")
                return false
            }
            guard let _ = competitionVideoPreviewImage else {
                displayMessage(message: "Unable to generate preview image")
                return false
            }
        }
        
        return true
    }
    
    private func createCompetitionEntry(
        videoPreviewImageId: String?,
        videoPreviewImageSmallId: String?,
        videoId: String?,
        imageId: String?,
        imageSmallId: String?,
        completion: @escaping SuccessCompletion
    ) {
        CompetitionEntryService.instance.createCompetitionEntry(
            categoryType: selectedCategory!.categoryType,
            competitionType: competitionType,
            caption: captionTextView.text,
            videoPreviewImageId: videoPreviewImageId,
            videoPreviewImageSmallId: videoPreviewImageSmallId,
            videoId: videoId,
            imageId: imageId,
            imageSmallId: imageSmallId
        ) { (success) in
            completion(success)
        }
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

extension CompetitionDetailsVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a caption..." {
            textView.text.removeAll()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a caption..."
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = keyboardToolbar
        return true
    }
}

extension CompetitionDetailsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryCollection.instance.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let categoryCell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_CELL, for: indexPath) as? CategoryCell {
            categoryCell.configureCell(category: CategoryCollection.instance.categories[indexPath.row])
            return categoryCell
        }
        return CategoryCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension CompetitionDetailsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = CategoryCollection.instance.categories[indexPath.row]
        configureView()
        tableView.isHidden = true
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
