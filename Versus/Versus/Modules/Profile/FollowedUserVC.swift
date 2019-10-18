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
    
    private let followerService = FollowerService.instance
    
    private var user: User!
    private var canEdit = false
    private var followedUsers = [FollowedUser]()
    private var keyboardToolbar: KeyboardToolbar!
    private var indexPathOfLastSelection: IndexPath?
    
    
    
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        followedUserTableView.register(
            UINib(nibName: FOLLOWED_USER_CELL, bundle: nil),
            forCellReuseIdentifier: FOLLOWED_USER_CELL
        )
        
        canEdit = CurrentAccount.userIsMe(userId: user.id)
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        loadFollowedUsers(userId: user.id)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indexPathOfLastSelection = nil
    }
    
    
    
    
    /**
     
     */
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    /**
     
     */
    private func loadFollowedUsers(userId: Int) {
        
        followerService.loadFollowedUsers(
            userId: userId
        ) { [weak self] (followedUsers, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let followedUsers = followedUsers else {
                    self?.displayMessage(message: "Unable to load followed users")
                    return
                }
                
                self?.followedUsers = followedUsers
                self?.followedUserTableView.reloadData()
            }
        }
    }
    
    
    /**
    
     */
    private func filterFollowedUsers(filter: String) {
//        guard !filter.isEmpty else {
//            filteredFollowedUsers = nil
//            followedUserTableView.reloadData()
//            return
//        }
//        filteredFollowedUsers = allFollowedUsers.filter({ $0.searchUsername.contains(filter.lowercased())
//            || $0.searchDisplayName.contains(filter.lowercased() )})
//        followedUserTableView.reloadData()
    }

    
    /**
     
     */
    private func showFollowedUserProfileAt(indexPath: IndexPath) {
        
        let user = followedUsers[indexPath.row].user
        let delegate = canEdit ? self : nil
        
        let userVC = UserVC(
            user: user,
            delegate: delegate
        )
        navigationController?.pushViewController(
            userVC,
            animated: true
        )
    }
    
    
    private func unfollowUser(indexPath: IndexPath) {
        
        let user = followedUsers[indexPath.row].user
        
        let unfollowAlert = UIAlertController(
            title: "Confirm Unfollow",
            message: "Are you sure you want to unfollow @\(user.username)",
            preferredStyle: .actionSheet
        )
        
        let unfollowAction = UIAlertAction(
            title: "Unfollow",
            style: .destructive
        ) { (action) in
            
            self.loadAndUnfollowUser(indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        unfollowAlert.addAction(unfollowAction)
        unfollowAlert.addAction(cancelAction)
        
        present(
            unfollowAlert,
            animated: true,
            completion: nil
        )
    }
    
    
    private func loadAndUnfollowUser(indexPath: IndexPath) {
        
        let userId = CurrentAccount.user.id
        let userFollowed = followedUsers[indexPath.row].user
        
        followerService.getFollowedUser(
            userId: userId,
            followedUserId: userFollowed.id
        ) { [weak self] (followedUser, errorMessage) in
            
            if let errorMessage = errorMessage {
                DispatchQueue.main.async {
                    self?.displayMessage(message: errorMessage)
                }
                return
            }
            
            guard let followedUser = followedUser else {
                DispatchQueue.main.async {
                    self?.displayMessage(message: "Unable to unfollow user")
                }
                return
            }
            
            self?.followerService.unfollow(
                followerId: followedUser.id,
                completion: { [weak self] (errorMessage) in
                    
                    DispatchQueue.main.async {
                        
                        if let errorMessage = errorMessage {
                            self?.displayMessage(message: errorMessage)
                            return
                        }
                        
                        CurrentAccount.removeFollowedUserId(id: userFollowed.id)
                        
                        self?.removeRowAt(indexPath: indexPath)
                    }
                }
            )
        }
    }
    
    
    /**
     
     */
    private func removeRowAt(indexPath: IndexPath) {
        
        followedUsers.remove(at: indexPath.row)
        
        DispatchQueue.main.async {
            self.followedUserTableView.deleteRows(
                at: [indexPath],
                with: .top
            )
        }
    }
}




extension FollowedUserVC: UserVCDelegate {
    
    
    func userUpdated() {
        
        guard let indexPath = indexPathOfLastSelection else {
            return
        }
        
        removeRowAt(indexPath: indexPath)
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
        
//        if followedUsers.isEmpty {
//            searchBar.text?.removeAll()
//            filteredFollowedUsers = nil
//            followedUserTableView.reloadData()
//        }
    }
    
    /**
     
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
//        filteredFollowedUsers = nil
//        followedUserTableView.reloadData()
    }
    
    /**
     
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowedUsers(filter: searchText)
    }
}




extension FollowedUserVC: FollowedUserCellDelegate {
    
    
    func unfollowUserAt(cell: UITableViewCell) {
        
        if let indexPath = followedUserTableView.indexPath(for: cell) {
            unfollowUser(indexPath: indexPath)
        }
    }
}




extension FollowedUserVC: UITableViewDataSource {
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return followedUsers.count
    }
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FOLLOWED_USER_CELL,
            for: indexPath
        )
        
        if let followedUserCell = cell as? FollowedUserCell {
            
            let followedUser = followedUsers[indexPath.row]
            //TODO
            followedUserCell.configureCell(
                followedUser: followedUser,
                delegate: self,
                profileImage: nil
            )
            return followedUserCell
        }
        return FollowedUserCell()
    }
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 70
    }
}




extension FollowedUserVC: UITableViewDelegate {
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        indexPathOfLastSelection = indexPath
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        showFollowedUserProfileAt(indexPath: indexPath)
    }
}
