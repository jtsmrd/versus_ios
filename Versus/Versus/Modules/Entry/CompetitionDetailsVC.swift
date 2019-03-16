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

    private let competitionEntryService = EntryService.instance
    private let categoryCollection = CategoryCollection.instance
    private let CATEGORY_CELL_HEIGHT: CGFloat = 50.0
    private let CAPTION_DEFAULT_TEXT = "Write a caption..."
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var selectCategoryView: BorderView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadStatusLabel: UILabel!
    
    @IBOutlet weak var categoryTableViewHeight: NSLayoutConstraint!
    
    var media: AnyObject!
    var previewImageTime: CMTime!
    var competitionType: CompetitionType!
    var selectedCategory: Category?
    var keyboardToolbar: KeyboardToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        
        submitButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.tableFooterView = UIView()
        
        selectCategoryView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(categoryViewTapped)
            )
        )
        
        determineCompetitionType()
    }
    
    
    deinit {
        selectCategoryView.gestureRecognizers?.removeAll()
    }
    
    
    /// Required object initializer.
    ///
    /// - Parameters:
    ///   - media: An AVURLAsset or UIImage to upload for a competition.
    ///   - previewImageTime: (Optional) When uploading a video, specify a
    ///     time in the video to generate the preview image.
    func initData(media: AnyObject, previewImageTime: CMTime? = nil) {
        self.media = media
        
        if let time = previewImageTime {
            self.previewImageTime = time
        }
        else {
            
            // Default the image generation time to 2 seconds
            self.previewImageTime = CMTime(value: Int64(2), timescale: 1)
        }
    }
    
    
    /// Navigate to the previous view controller.
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    /// Submit the competition entry.
    @IBAction func submitButtonAction() {
        submitEntry()
    }
    
    
    /// Share to Facebook.
    @IBAction func facebookButtonAction() {
        
    }
    
    
    /// Share to Instagram.
    @IBAction func instagramButtonAction() {
        
    }
    
    
    /// Share to Twitter.
    @IBAction func twitterButtonAction() {
        
    }
    
    
    /// Show or hide the categories table view.
    @objc func categoryViewTapped() {
        
        if categoryTableViewHeight.constant == CATEGORY_CELL_HEIGHT {
            showCategories()
        }
        else {
            hideCategories()
        }
    }
    
    
    /// Show the categories table view and animate it's height constraint.
    private func showCategories() {
        
        contentView.bringSubviewToFront(categoryTableView)
        
        let expandHeight = CGFloat(categoryCollection.categories.count) * CATEGORY_CELL_HEIGHT
        
        UIView.animate(withDuration: 0.5) {
            self.categoryTableViewHeight.constant = expandHeight
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// Hide the categories table view and animate it's height constraint.
    private func hideCategories() {
        
        contentView.bringSubviewToFront(selectCategoryView)
        
        let contractHeight = CATEGORY_CELL_HEIGHT
        
        UIView.animate(withDuration: 0.5) {
            self.categoryTableViewHeight.constant = contractHeight
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// Sets the competitionType and preview image. Could fail if media contains
    /// an Object other than UIImage or AVURLAsset, or if image generation failed.
    private func determineCompetitionType() {
        
        switch media {
        case let image as UIImage:
            
            previewImageView.image = image
            competitionType = .image
            return
            
        case let videoAsset as AVURLAsset:
            
            guard let image = Utilities.generateImage(videoAsset: videoAsset, time: previewImageTime) else { break }
            
            previewImageView.image = image
            competitionType = .video
            return
            
        default:
            break
        }
        
        displayMessage(message: "Unsupported file type, please select a new file to upload.")
    }
    
    
    /// Validate, set loading state, and submit an image or video competition
    /// based on the type of media object.
    private func submitEntry() {
        
        view.endEditing(true)
        
        guard let category = selectedCategory else {
            displayMessage(message: "Please select a category")
            return
        }
        
        // If the caption text is the default text, set to nil
        let caption = captionTextView.text == CAPTION_DEFAULT_TEXT ? nil : captionTextView.text
        
        setLoadingState(isLoading: true)
        
        switch media {
        case let image as UIImage:
        
            submitImageCompetition(
                image: image,
                caption: caption,
                categoryType: category.categoryType,
                displayName: CurrentUser.displayName,
                isFeatured: CurrentUser.isFeatured,
                rank: CurrentUser.rank,
                userId: CurrentUser.userId,
                username: CurrentUser.username
            )
            return
            
        case let videoAsset as AVURLAsset:

            guard let image = Utilities.generateImage(videoAsset: videoAsset, time: previewImageTime) else { break }
            
            submitVideoCompetition(
                image: image,
                videoAsset: videoAsset,
                caption: caption,
                categoryType: category.categoryType,
                displayName: CurrentUser.displayName,
                isFeatured: CurrentUser.isFeatured,
                rank: CurrentUser.rank,
                userId: CurrentUser.userId,
                username: CurrentUser.username
            )
            return
            
        default:
            break
        }
        
        displayMessage(message: "Unable to submit competition entry, please try again.")
    }
    
    
    /// Configures the controls in the view for the loading state and
    /// non-loading state.
    ///
    /// - Parameter isLoading: The loading state to be set.
    private func setLoadingState(isLoading: Bool) {
        
        if isLoading {
            
            submitButton.isEnabled = false
            activityIndicator.startAnimating()
            uploadStatusLabel.isHidden = false
        }
        else {
            
            submitButton.isEnabled = true
            activityIndicator.stopAnimating()
            uploadStatusLabel.isHidden = true
        }
    }
    
    
    /// Submits an image competition.
    ///
    /// - Parameters:
    ///   - image: The image to upload.
    ///   - categoryType: The category type of the competition.
    ///   - caption: The caption for the competition.
    private func submitImageCompetition(
        image: UIImage,
        caption: String?,
        categoryType: CategoryType,
        displayName: String,
        isFeatured: Bool,
        rank: Rank,
        userId: String,
        username: String
    ) {
        
        competitionEntryService.submitImageEntry(
            image: image,
            caption: caption,
            categoryType: categoryType,
            displayName: displayName,
            isFeatured: isFeatured,
            rank: rank,
            userId: userId,
            username: username
        ) { (customError) in
            
            DispatchQueue.main.async {
                
                if let customError = customError {
                    
                    self.displayError(error: customError)
                    self.setLoadingState(isLoading: false)
                    return
                }
                
                self.performSegue(withIdentifier: SHOW_COMPETITION_SUBMITTED, sender: nil)
            }
        }
    }
    
    
    /// Submits a video competition.
    ///
    /// - Parameters:
    ///   - videoAsset: The video asset to upload.
    ///   - image: The preview image to upload.
    ///   - categoryType: The category type of the competition.
    ///   - caption: The caption for the competition.
    private func submitVideoCompetition(
        image: UIImage,
        videoAsset: AVURLAsset,
        caption: String?,
        categoryType: CategoryType,
        displayName: String,
        isFeatured: Bool,
        rank: Rank,
        userId: String,
        username: String
    ) {
        
        competitionEntryService.submitVideoEntry(
            image: image,
            video: videoAsset,
            caption: caption,
            categoryType: categoryType,
            displayName: displayName,
            isFeatured: isFeatured,
            rank: rank,
            userId: userId,
            username: username
        ) { (customError) in
            
            DispatchQueue.main.async {
                
                if let customError = customError {
                    
                    self.displayError(error: customError)
                    self.setLoadingState(isLoading: false)
                    return
                }
                
                self.performSegue(withIdentifier: SHOW_COMPETITION_SUBMITTED, sender: nil)
            }
        }
    }
}

extension CompetitionDetailsVC: UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // Remove the default text when editing.
        if textView.text == CAPTION_DEFAULT_TEXT {
            textView.text.removeAll()
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // Add default text if empty when editing ended.
        if textView.text.isEmpty {
            textView.text = CAPTION_DEFAULT_TEXT
        }
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        // Add keyboard toolbar to dismiss keyboard.
        textView.inputAccessoryView = keyboardToolbar
        return true
    }
}

extension CompetitionDetailsVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryCollection.categories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let categoryCell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_CELL, for: indexPath) as? CategoryCell {
            
            categoryCell.configureCell(category: categoryCollection.categories[indexPath.row])
            return categoryCell
        }
        
        return CategoryCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CATEGORY_CELL_HEIGHT
    }
}

extension CompetitionDetailsVC: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let category = categoryCollection.categories[indexPath.row]
        
        // Configure the selectedCategoryView with the selected category.
        categoryLabel.text = category.title
        categoryLabel.textColor = UIColor.white
        categoryImageView.image = UIImage(named: category.iconName)
        selectCategoryView.backgroundColor = category.backgroundColor
        
        selectedCategory = category
        
        // Hide the categories tableView after category is selected.
        hideCategories()
    }
}
