//
//  CompetitionDetailsVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionDetailsVC: UIViewController {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var selectCategoryView: BorderView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTableView: UITableView!
    
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        selectCategoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryViewTapped)))
    }

    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction() {
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
