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
    
    var searchResultUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchUserTableView.reloadData()
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
            return 0
        }
        else {
            return searchResultUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == browseTableView {
            return UITableViewCell()
        }
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_USER_CELL, for: indexPath) as? SearchUserCell {
                cell.configureCell(user: searchResultUsers[indexPath.row], delegate: self)
                return cell
            }
            return SearchUserCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == browseTableView {
            return 50
        }
        else {
            return 70
        }
    }
}

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
            profileVC.initData(profileViewMode: .viewOnly, user: searchResultUsers[indexPath.row])
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
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
