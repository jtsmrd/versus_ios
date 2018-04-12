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

        // Do any additional setup after loading the view.
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as? SearchUserCell {
                cell.configureCell(user: searchResultUsers[indexPath.row])
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
    
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchUserTableView.isHidden = false
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchUserTableView.isHidden = true
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            searchResultUsers.removeAll()
            searchUserTableView.reloadData()
            return
        }
        
        UserService.instance.queryUsers(queryString: searchText) { (users) in
            if let users = users {
                self.searchResultUsers = users
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
