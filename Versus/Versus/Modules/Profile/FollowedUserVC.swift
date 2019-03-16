//
//  FollowedUserVC.swift
//  Versus
//
//  Created by JT Smrdel on 8/15/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowedUserVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followedUserTableView: UITableView!
    
    var user: User!
    var canEdit = false
    var allFollowedUsers = [FollowedUser]()
    var filteredFollowedUsers: [FollowedUser]?
    var followedUsers: [FollowedUser] {
        return filteredFollowedUsers ?? allFollowedUsers
    }
    var keyboardToolbar: KeyboardToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO
//        canEdit = CurrentUser.userId == user.userId
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        getFollowedUsers()
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
    private func getFollowedUsers() {
        //TODO
//        user.getFollowedUsers { (followedUsers, customError) in
//            DispatchQueue.main.async {
//                if let customError = customError {
//                    self.displayError(error: customError)
//                    return
//                }
//                self.allFollowedUsers.append(contentsOf: followedUsers)
//                self.followedUserTableView.reloadData()
//            }
//        }
    }
    
    
    /**
    
     */
    private func filterFollowedUsers(filter: String) {
        guard !filter.isEmpty else {
            filteredFollowedUsers = nil
            followedUserTableView.reloadData()
            return
        }
        filteredFollowedUsers = allFollowedUsers.filter({ $0.searchUsername.contains(filter.lowercased())
            || $0.searchDisplayName.contains(filter.lowercased() )})
        followedUserTableView.reloadData()
    }

    
    /**
     
     */
    private func showFollowedUserProfile(followedUserUserId: String) {
        if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
            //TODO
//            profileVC.initData(userId: followedUserUserId)
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    
    /**
     
     */
    private func removeRow(at index: Int) {
        allFollowedUsers.remove(at: index)
        
        // If the followedUsers are filtered, remove from the filtered collection as well
        if filteredFollowedUsers != nil {
            filteredFollowedUsers!.remove(at: index)
        }
        
        DispatchQueue.main.async {
            self.followedUserTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
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

extension FollowedUserVC: ProfileVCDelegate {
    
    /**
     
     */
    func unfollowedUser(user: User) {
        //TODO
//        if canEdit {
//            if let index = followedUsers.index(where: { $0.followedUserUserId == user.userId }) {
//                removeRow(at: index)
//            }
//        }
    }
}

extension FollowedUserVC: UISearchBarDelegate {
    
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
        
        if followedUsers.isEmpty {
            searchBar.text?.removeAll()
            filteredFollowedUsers = nil
            followedUserTableView.reloadData()
        }
    }
    
    /**
     
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
        filteredFollowedUsers = nil
        followedUserTableView.reloadData()
    }
    
    /**
     
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowedUsers(filter: searchText)
    }
}

extension FollowedUserVC: FollowedUserCellDelegate {
    
    
    /**
     
     */
    func followedUserCellFollowButtonActionError(error: CustomError) {
        displayError(error: error)
    }
    
    
    /**
     
     */
    func followedUserCellFollowButtonActionUnfollow(followedUser: FollowedUser) {
        //TODO
//        if canEdit {
//            if let index = followedUsers.index(where: { $0.followedUserUserId == user.userId }) {
//                removeRow(at: index)
//            }
//        }
//        FollowerService.instance.removeFollowerFromFollowedUsers(awsFollower: follower.awsFollower)
    }
}

extension FollowedUserVC: UITableViewDataSource {
    
    /**
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followedUsers.count
    }
    
    /**
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FOLLOWED_USER_CELL, for: indexPath) as? FollowedUserCell {
            cell.configureCell(followedUser: followedUsers[indexPath.row], delegate: self)
            return cell
        }
        return FollowedUserCell()
    }
    
    /**
     
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension FollowedUserVC: UITableViewDelegate {
    
    /**
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFollowedUserProfile(followedUserUserId: followedUsers[indexPath.row].followedUserUserId)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
