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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension RankVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RankCollection.instance.ranks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell", for: indexPath) as? RankCell {
            cell.configureCell(rank: RankCollection.instance.ranks[indexPath.row])
            return cell
        }
        return RankCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

extension RankVC: UITableViewDelegate {
    
}
