//
//  UnmatchedEntriesVC.swift
//  Versus
//
//  Created by JT Smrdel on 1/4/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class UnmatchedEntriesVC: UIViewController {

    
    @IBOutlet weak var unmatchedEntriesTableView: UITableView!
    
    private var unmatchedEntries: [CompetitionEntry]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    func initData(unmatchedEntries: [CompetitionEntry]) {
        self.unmatchedEntries = unmatchedEntries
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UnmatchedEntriesVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unmatchedEntries.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UNMATCHED_ENTRY_CELL, for: indexPath)
        
        if let unmatchedEntryCell = cell as? UnmatchedEntryCell {
            
            let unmatchedEntry = unmatchedEntries[indexPath.row]
            unmatchedEntryCell.configureCell(competitionEntry: unmatchedEntry)
            
            return unmatchedEntryCell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension UnmatchedEntriesVC: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
