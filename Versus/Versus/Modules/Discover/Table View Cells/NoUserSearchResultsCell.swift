//
//  NoUserSearchResultsCell.swift
//  Versus
//
//  Created by JT Smrdel on 3/24/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class NoUserSearchResultsCell: UITableViewCell {

    @IBOutlet weak var noResultsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(searchText: String) {
        
        noResultsLabel.text = String(
            format: "No results found for: \"%@\"",
            searchText
        )
    }
}
