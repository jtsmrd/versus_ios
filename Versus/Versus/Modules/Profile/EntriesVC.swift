//
//  EntriesVC.swift
//  Versus
//
//  Created by JT Smrdel on 1/4/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class EntriesVC: UIViewController {

    
    @IBOutlet weak var entriesTableView: UITableView!
    
    private var entries: [Entry]!
    
    
    
    
    init(entries: [Entry]) {
        super.init(nibName: nil, bundle: nil)
        self.entries = entries
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        entriesTableView.register(
            UINib(nibName: ENTRY_CELL, bundle: nil),
            forCellReuseIdentifier: ENTRY_CELL
        )
        
        entriesTableView.tableFooterView = UIView()
    }
    
    
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}




extension EntriesVC: UITableViewDataSource {
    
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return entries.count
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ENTRY_CELL,
            for: indexPath
        )
        
        if let entryCell = cell as? EntryCell {
            
            let entry = entries[indexPath.row]
            //TODO
            entryCell.configureCell(
                entry: entry,
                entryImage: nil
            )
            return entryCell
        }
        return UITableViewCell()
    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 80.0
    }
}




extension EntriesVC: UITableViewDelegate {
    
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
    }
}
