//
//  DiscoverCategoryCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class DiscoverCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categorySelectedView: CircleView!
    @IBOutlet weak var categoryImageView: CircleImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    var categorySelected = false
    var category: Category!
    var defaultFont: UIFont?
    var selectedFont: UIFont?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        defaultFont = categoryTitleLabel.font
        selectedFont = UIFont(name: categoryTitleLabel.font.fontName + "-Bold", size: categoryTitleLabel.font.pointSize)
    }
    
    func configureCell(category: Category, selected: Bool) {
        
        self.category = category
        categorySelected = selected
        categoryImageView._backgroundColor = CategoryCollection.instance.categoryColorFor(categoryTypeId: category.categoryType.rawValue)
        categoryImageView.image = CategoryCollection.instance.categoryIconFor(categoryTypeId: category.categoryType.rawValue)
        categoryTitleLabel.text = category.title
        
        if categorySelected {
            categorySelectedView._backgroundColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            categoryTitleLabel.font = selectedFont
            categoryTitleLabel.font = categoryTitleLabel.font.withSize(12.0)
            categoryTitleLabel.textColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        }
        else {
            categorySelectedView._backgroundColor = UIColor.clear
            categoryTitleLabel.font = defaultFont
            categoryTitleLabel.textColor = UIColor.darkGray
        }
        categorySelectedView.setNeedsDisplay()
        categoryImageView.setNeedsDisplay()
    }
    
    func toggleSelected(selected: Bool) {
        categorySelected = selected
        if categorySelected {
            categorySelectedView._backgroundColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            categoryTitleLabel.font = selectedFont
            categoryTitleLabel.font = categoryTitleLabel.font.withSize(12.0)
            categoryTitleLabel.textColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        }
        else {
            categorySelectedView._backgroundColor = UIColor.clear
            categoryTitleLabel.font = defaultFont
            categoryTitleLabel.textColor = UIColor.darkGray
        }
        categorySelectedView.setNeedsDisplay()
    }
}
