//
//  RankVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class RankVC: UIViewController {

    
    @IBOutlet weak var rankTableView: UITableView!
    
    var user: User!    
    
    
    
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rankTableView.register(
            UINib(nibName: "RankCell", bundle: nil),
            forCellReuseIdentifier: "RankCell"
        )
        
        rankTableView.tableFooterView = UIView()
    }
    
    
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}




extension RankVC: UITableViewDataSource {
    
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return Rank.allCases.count
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RankCell",
            for: indexPath
        )
        
        if let rankCell = cell as? RankCell {
            
            let rank = Rank(rankId: (indexPath.row + 1))
            
            rankCell.configureCell(
                user: user,
                rank: rank
            )
            return rankCell
        }
        return RankCell()
    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 100.0
    }
}




extension RankVC: UITableViewDelegate {
    
}
