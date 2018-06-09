//
//  FollowerVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum FollowersViewType: String {
    case following = "Following"
    case follower = "Followers"
}

enum FollowersViewMode {
    case edit
    case viewOnly
}

class FollowerVC: UIViewController {

    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followerTableView: UITableView!
    
    
    var followersViewType: FollowersViewType = .following
    var followerViewMode: FollowersViewMode = .viewOnly
    var allFollowers = [Follower]()
    var filteredFollowers: [Follower]?
    var followers: [Follower] {
        return filteredFollowers ?? allFollowers
    }
    var keyboardToolbar: KeyboardToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
        keyboardToolbar = KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50), includeNavigation: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        followerTableView.reloadData()
    }

    
    func initData(followersViewType: FollowersViewType, followerViewMode: FollowersViewMode, followers: [Follower]) {
        self.followersViewType = followersViewType
        self.followerViewMode = followerViewMode
        self.allFollowers = followers
    }
    
    
    private func configureView() {
        
        viewTitleLabel.text = followersViewType.rawValue
    }
    
    
    private func filterFollowers(filter: String) {
        
        guard !filter.isEmpty else {
            filteredFollowers = nil
            followerTableView.reloadData()
            return
        }
        
        let filterText = filter.lowercased()
        
        filteredFollowers = allFollowers.filter({ (follower) -> Bool in

            var filterUsername: String?
            var filterDisplayName: String?
            
            // Filter attribute is different for following/ follower
            switch followersViewType {
            case .following:
                filterUsername = follower.awsFollower._followedUserUsername?.lowercased()
                filterDisplayName = follower.awsFollower._followedUserDisplayName?.lowercased()
            case .follower:
                filterUsername = follower.awsFollower._followerUsername?.lowercased()
                filterDisplayName = follower.awsFollower._followerDisplayName?.lowercased()
            }
            
            guard let username = filterUsername else { return false }
            
            if let displayName = filterDisplayName {
                return username.contains(filterText) || displayName.contains(filterText)
            }
            else {
                return username.contains(filterText)
            }
        })
        
        followerTableView.reloadData()
    }
    
    
    private func showFollowerProfile(follower: Follower) {
        
        UserService.instance.loadUser(fromFollower: follower) { (awsUser, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if let awsUser = awsUser {
                    if let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                        profileVC.initData(profileViewMode: .viewOnly, user: User(awsUser: awsUser))
                        profileVC.delegate = self.followerViewMode == .edit ? self : nil
                        profileVC.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                }
            }
        }
    }
    
    
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
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension FollowerVC: ProfileVCDelegate {
    
    func unfollowedUser(user: User) {
        if followerViewMode == .edit,
            followersViewType == .following,
            let index = followers.index(where: {$0.awsFollower._followedUserId == user.awsUser._userPoolUserId}) {
            removeRow(at: index)
        }
    }
}

extension FollowerVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        if followers.isEmpty {
            searchBar.text?.removeAll()
            filteredFollowers = nil
            followerTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
        filteredFollowers = nil
        followerTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowers(filter: searchText)
    }
}

extension FollowerVC: FollowerCellDelegate {
    
    func followerCellFollowButtonActionError(error: CustomError) {
        displayError(error: error)
    }
    
    func followerCellFollowButtonActionUnfollow(follower: Follower) {
        
        if followerViewMode == .edit,
            followersViewType == .following,
            let index = followers.index(where: {$0.awsFollower._id == follower.awsFollower._id}) {
            removeRow(at: index)
        }
        FollowerService.instance.removeFollowerFromFollowedUsers(user: CurrentUser.user, awsFollower: follower.awsFollower)
    }
}

extension FollowerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FOLLOWER_CELL, for: indexPath) as? FollowerCell {
            cell.configureCell(follower: followers[indexPath.row], delegate: self)
            return cell
        }
        return FollowerCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension FollowerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFollowerProfile(follower: followers[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
