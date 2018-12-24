//
//  FollowerVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowerVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followerTableView: UITableView!
    
    var user: User!
    var canEdit = false
    var allFollowers = [Follower]()
    var filteredFollowers: [Follower]?
    var followers: [Follower] {
        return filteredFollowers ?? allFollowers
    }
    var keyboardToolbar: KeyboardToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canEdit = CurrentUser.userId == user.userId
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        getFollowers()
    }

    
    /**
     
     */
    func initData(user: User) {
        self.user = user
    }
    
    
    /**
     
     */
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    /**
     
     */
    private func getFollowers() {
        user.getFollowers { (followers, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                    return
                }
                self.allFollowers.append(contentsOf: followers)
                self.followerTableView.reloadData()
            }
        }
    }
    
    
    /**
     
     */
    private func filterFollowers(filter: String) {
        
        guard !filter.isEmpty else {
            filteredFollowers = nil
            followerTableView.reloadData()
            return
        }
        filteredFollowers = allFollowers.filter({ $0.searchUsername.contains(filter.lowercased()) || $0.searchDisplayName.contains(filter.lowercased()) })
        followerTableView.reloadData()
    }
    
    
    /**
     
     */
    private func showFollowerProfile(followerUserId: String) {
        if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
            profileVC.initData(userId: followerUserId)
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    /**
     
     */
    private func removeRow(at index: Int) {
        allFollowers.remove(at: index)
        
        // If the followers are filtered, remove from the filtered collection as well
        if filteredFollowers != nil {
            filteredFollowers!.remove(at: index)
        }
        
        DispatchQueue.main.async {
            self.followerTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
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

extension FollowerVC: ProfileVCDelegate {
    
    /**
     
     */
    func unfollowedUser(user: User) {
        if canEdit {
            if let index = followers.index(where: { $0.followerUserId == user.userId }) {
                removeRow(at: index)
            }
        }
    }
}

extension FollowerVC: UISearchBarDelegate {
    
    /**
     
     */
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    /**
     
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    /**
     
     */
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        if followers.isEmpty {
            searchBar.text?.removeAll()
            filteredFollowers = nil
            followerTableView.reloadData()
        }
    }
    
    /**
     
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
        filteredFollowers = nil
        followerTableView.reloadData()
    }
    
    /**
     
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowers(filter: searchText)
    }
}

extension FollowerVC: FollowerCellDelegate {
    
    /**
     
     */
    func followerCellFollowButtonActionError(error: CustomError) {
        displayError(error: error)
    }
    
    /**
     
     */
    func followerCellFollowButtonActionUnfollow(follower: Follower) {
        if canEdit {
            if let index = followers.index(where: { $0.followerUserId == user.userId }) {
                removeRow(at: index)
            }
        }
//        FollowerService.instance.removeFollowerFromFollowedUsers(awsFollower: follower.awsFollower)
    }
}

extension FollowerVC: UITableViewDataSource {
    
    /**
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    /**
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FOLLOWER_CELL, for: indexPath) as? FollowerCell {
            cell.configureCell(follower: followers[indexPath.row], delegate: self)
            return cell
        }
        return FollowerCell()
    }
    
    /**
     
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension FollowerVC: UITableViewDelegate {
    
    /**
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFollowerProfile(followerUserId: followers[indexPath.row].followerUserId)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
