//
//  SearchVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var browseTableView: UITableView!
    @IBOutlet weak var searchUserTableView: UITableView!
    @IBOutlet weak var leaderboardCollectionView: UICollectionView!
    @IBOutlet weak var browseCategoryCollectionView: UICollectionView!
    
    
    var searchResultUsers = [User]()
    var featuredCompetitions = [Competition]()
    var selectedCategoryIndexPath: IndexPath?
    let leaderboardCollectionViewSectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    let browseCategoryCollectionViewSectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    let testLeaderboardNames = ["Weekly Leaders", "Monthly Leaders", "All-Time Leaders"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFeaturedCompetitions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchUserTableView.reloadData()
    }

    
    
    private func getFeaturedCompetitions() {
        
        CompetitionService.instance.getFeaturedCompetitions { (competitions, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else {
                    self.featuredCompetitions.removeAll()
                    self.featuredCompetitions.append(contentsOf: competitions)
                    self.browseTableView.reloadData()
                }
            }
        }
    }
    
    
    private func getFeaturedCompetitionsWith(categoryId: Int) {
        
        CompetitionService.instance.getFeaturedCompetitionsWith(
            categoryId: categoryId
        ) { (competitions, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else {
                    self.featuredCompetitions.removeAll()
                    self.featuredCompetitions.append(contentsOf: competitions)
                    self.browseTableView.reloadData()
                }
            }
        }
    }
    
    
    private func showCompetition(competition: Competition) {
        
        if let viewCompetitionVC = UIStoryboard(name: COMPETITION, bundle: nil).instantiateInitialViewController() as? ViewCompetitionVC {
            viewCompetitionVC.initData(competition: competition)
            navigationController?.pushViewController(viewCompetitionVC, animated: true)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension SearchVC: SearchUserCellDelegate {
    
    func searchUserCellFollowButtonActionError(error: CustomError) {
        self.displayError(error: error)
    }
}

extension SearchVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == browseTableView {
            return featuredCompetitions.count
        }
        else if tableView == searchUserTableView {
            return searchResultUsers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == browseTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: COMPETITION_CELL, for: indexPath) as? CompetitionCell {
                cell.configureCell(competition: featuredCompetitions[indexPath.row])
                return cell
            }
            return CompetitionCell()
        }
        else if tableView == searchUserTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_USER_CELL, for: indexPath) as? SearchUserCell {
                cell.configureCell(user: searchResultUsers[indexPath.row], delegate: self)
                return cell
            }
            return SearchUserCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == browseTableView {
            return 188
        }
        else if tableView == searchUserTableView {
            return 70
        }
        return 0
    }
}

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == browseTableView {
            showCompetition(competition: featuredCompetitions[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: false)
        }
        else if tableView == searchUserTableView {
            
            if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
                profileVC.initData(profileViewMode: .viewOnly, user: searchResultUsers[indexPath.row])
                profileVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(profileVC, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchUserTableView.isHidden = false
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchUserTableView.isHidden = true
        searchBar.text?.removeAll()
        searchResultUsers.removeAll()
        searchUserTableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            searchResultUsers.removeAll()
            searchUserTableView.reloadData()
            return
        }
        
        UserService.instance.queryUsers(queryString: searchText) { (awsUsers) in
            if let awsUsers = awsUsers {
                self.searchResultUsers.removeAll()
                for awsUser in awsUsers {
                    if !CurrentUser.userIsMe(awsUser: awsUser) {
                        self.searchResultUsers.append(User(awsUser: awsUser))
                    }
                }
                DispatchQueue.main.async {
                    self.searchUserTableView.reloadData()
                }
            }
            else {
                debugPrint("No users found")
            }
        }
    }
}


extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == leaderboardCollectionView {
            return testLeaderboardNames.count
        }
        else if collectionView == browseCategoryCollectionView {
            return CategoryCollection.instance.categories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == leaderboardCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LEADERBOARD_CELL, for: indexPath) as? LeaderboardCell {
                cell.configureCell(title: testLeaderboardNames[indexPath.row])
                return cell
            }
            return LeaderboardCell()
        }
        else if collectionView == browseCategoryCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BROWSE_CATEGORY_CELL, for: indexPath) as? BrowseCategoryCell {
                
                if let categoryIndexPath = selectedCategoryIndexPath, categoryIndexPath == indexPath {
                    cell.configureCell(category: CategoryCollection.instance.categories[indexPath.row], selected: true)
                }
                else {
                    cell.configureCell(category: CategoryCollection.instance.categories[indexPath.row], selected: false)
                }
                return cell
            }
            return BrowseCategoryCell()
        }
        return UICollectionViewCell()
    }
}


extension SearchVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == leaderboardCollectionView {
            
        }
        else if collectionView == browseCategoryCollectionView {
            
            let cell = collectionView.cellForItem(at: indexPath) as! BrowseCategoryCell
            cell.toggleSelected(selected: !cell.categorySelected)
            
            if cell.categorySelected {
                selectedCategoryIndexPath = indexPath
                getFeaturedCompetitionsWith(categoryId: cell.category.categoryType.rawValue)
            }
            else {
                selectedCategoryIndexPath = nil
                getFeaturedCompetitions()
            }
            collectionView.reloadData()
        }
    }
}

extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == leaderboardCollectionView {
            
            let itemsPerRow: CGFloat = 3
            
            let paddingSpace = leaderboardCollectionViewSectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: collectionView.frame.height)
        }
        else if collectionView == browseCategoryCollectionView {
            
            let itemsPerRow: CGFloat = 5.5
            
            let paddingSpace = browseCategoryCollectionViewSectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: collectionView.frame.height)
        }
        return CGSize.zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == leaderboardCollectionView {
            return leaderboardCollectionViewSectionInsets
        }
        else if collectionView == browseCategoryCollectionView {
            return browseCategoryCollectionViewSectionInsets
        }
        return UIEdgeInsets.zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == leaderboardCollectionView {
            return leaderboardCollectionViewSectionInsets.left
        }
        else if collectionView == browseCategoryCollectionView {
            return browseCategoryCollectionViewSectionInsets.left
        }
        return 0.0
    }
}
