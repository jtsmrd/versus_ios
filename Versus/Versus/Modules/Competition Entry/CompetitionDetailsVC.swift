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

    private let competitionEntryService = CompetitionEntryService.instance
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var selectCategoryView: BorderView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTableView: UITableView!
    
    var image: UIImage!
    var video: AVURLAsset!
    var competitionType: CompetitionType!
    var selectedCategory: Category?
    var keyboardToolbar: KeyboardToolbar!
    
    
    /**
 
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardToolbar = KeyboardToolbar(
            frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50),
            includeNavigation: false
        )
        
        submitButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        selectCategoryView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(categoryViewTapped)
            )
        )
        
        configureView()
    }

    
    /**
 
     */
    func initData(image: UIImage) {
        self.image = image
        competitionType = .image
    }
    
    
    /**
     
     */
    func initData(image: UIImage, video: AVURLAsset) {
        self.image = image
        self.video = video
        competitionType = .video
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    /**
     
     */
    @IBAction func submitButtonAction() {
        
//        if let originalImage = image, let originalImageData = UIImageJPEGRepresentation(originalImage, 1.0), let compressedImage = image.compressImage(), let compressedImageData = UIImageJPEGRepresentation(compressedImage, 1.0) {
//            
//            let bcf = ByteCountFormatter()
//            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
//            bcf.countStyle = .file
//
//            let originalSize = bcf.string(fromByteCount: Int64(originalImageData.count))
//            print(String(format: "There are %d bytes in original image - %@", originalImageData.count, originalSize))
//
//            let compressedSize = bcf.string(fromByteCount: Int64(compressedImageData.count))
//            print(String(format: "There are %d bytes in compressed image - %@", compressedImageData.count, compressedSize))
//        }
        
        
        guard let category = selectedCategory else {
            displayMessage(message: "Select a category")
            return
        }
        let caption = captionTextView.text
        submitButton.isEnabled = false
        submitCompetitionEntry(
            categoryType: category.categoryType,
            caption: caption
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                    self.submitButton.isEnabled = true
                    return
                }
                self.performSegue(withIdentifier: SHOW_COMPETITION_SUBMITTED, sender: nil)
                self.submitButton.isEnabled = true
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
    
    
    /**
     
     */
    private func configureView() {
        previewImageView.image = image
        if let category = selectedCategory {
            categoryLabel.text = category.title
            categoryLabel.textColor = UIColor.white
            categoryImageView.image = UIImage(named: category.iconName)
            selectCategoryView.backgroundColor = category.backgroundColor
        }
        else {
            categoryLabel.textColor = UIColor.darkGray
        }
    }
    
    
    /**
     
     */
    private func submitCompetitionEntry(
        categoryType: CategoryType,
        caption: String?,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        switch competitionType! {
        case .image:
            competitionEntryService.submitImageCompetitionEntry(
                categoryType: categoryType,
                caption: caption,
                image: image,
                completion: completion
            )
        case .video:
            competitionEntryService.submitVideoCompetitionEntry(
                categoryType: categoryType,
                caption: caption,
                image: image,
                video: video,
                completion: completion
            )
        }
    }
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
