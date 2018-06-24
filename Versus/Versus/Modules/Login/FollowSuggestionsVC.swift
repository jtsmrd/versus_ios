//
//  FollowSuggestionsVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/7/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowSuggestionsVC: UIViewController {

    @IBOutlet weak var followSuggestionsCollectionView: UICollectionView!
    
    let sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var followerSuggestions = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFollowerSuggestions()
        
    }

    
    @IBAction func skipButtonAction() {
        performSegue(withIdentifier: SHOW_MAIN_STORYBOARD, sender: nil)
    }
    
    
    private func getFollowerSuggestions() {
        UserService.instance.querySuggestedFollowUsers { (users, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else {
                    self.followerSuggestions = users
                    self.followSuggestionsCollectionView.reloadData()
                }
            }
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

extension FollowSuggestionsVC: FollowerSuggestionCellDelegate {
    func followerSuggestionCellFollowButtonActionError(error: CustomError) {
        displayError(error: error)
    }
}

extension FollowSuggestionsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return followerSuggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FOLLOWER_SUGGESTION_CELL, for: indexPath) as? FollowerSuggestionCell {
            cell.configureCell(user: followerSuggestions[indexPath.row], delegate: self)
            return cell
        }
        return FollowerSuggestionCell()
    }
    
    
}

extension FollowSuggestionsVC: UICollectionViewDelegate {
    
}

extension FollowSuggestionsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 2
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
}
