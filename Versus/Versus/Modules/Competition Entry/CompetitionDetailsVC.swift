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

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var selectCategoryView: BorderView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTableView: UITableView!
    
    var competitionImage: UIImage?
    var competitionVideoAsset: AVAsset?
    var competitionType: CompetitionType = .image
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        selectCategoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryViewTapped)))
        
        configureView()
    }

    
    func initData(image: UIImage?, videoAsset: AVAsset?) {
        competitionImage = image
        competitionVideoAsset = videoAsset
        competitionType = image != nil ? .image : .video
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction() {
        
        guard inputDataIsValid() else { return }
        
        let uploadMediaDispatchGroup = DispatchGroup()
        
        switch competitionType {
        case .image:
            print()
        case .video:
            print()
        }
        
        uploadMediaDispatchGroup.notify(queue: .main) {
            
        }
        
        performSegue(withIdentifier: SHOW_COMPETITION_SUBMITTED, sender: nil)
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
            previewImageView.image = Utilities.generatePreviewImage(for: competitionVideoAsset!)
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
            guard let _ = competitionVideoAsset else {
                displayMessage(message: "Select competition video")
                return false
            }
        }
        
        return true
    }
    
    private func createCompetitionEntry() {
        
        
    }
    
    private func uploadCompetitionImage(
        image: UIImage,
        completion: @escaping SuccessCompletion
    ) {
        S3BucketService.instance.uploadImage(
            image: image,
            bucketType: .competitionImage
        ) { (success) in
            completion(success)
        }
    }
    
    private func uploadCompetitionVideo() {
        
    }
    
    private func uploadCompetitionVideoPreviewImage(
        image: UIImage,
        completion: @escaping SuccessCompletion
    ) {
        S3BucketService.instance.uploadImage(
            image: image,
            bucketType: .competitionVideoPreviewImage
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
