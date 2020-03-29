//
//  CategorySelectorVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/27/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

protocol CategorySelectorVCDelegate: class {
    func categorySelected(category: Category?)
}

class CategorySelectorVC: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    private let browseCategoryCollectionViewSectionInsets = UIEdgeInsets(
        top: 0,
        left: 2,
        bottom: 0,
        right: 2
    )
    
    private weak var delegate: CategorySelectorVCDelegate?
    private var selectedCategoryIndexPath: IndexPath?
    
    
    
    init(delegate: CategorySelectorVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryCollectionView.register(
            UINib(nibName: DISCOVER_CATEGORY_CELL, bundle: nil),
            forCellWithReuseIdentifier: DISCOVER_CATEGORY_CELL
        )
    }
}


// MARK: - UICollectionViewDataSource
extension CategorySelectorVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryCollection.instance.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DISCOVER_CATEGORY_CELL,
            for: indexPath
        ) as! DiscoverCategoryCell
        
        let category = CategoryCollection.instance.categories[indexPath.row]
        var selected = false
        
        if let categoryIndexPath = selectedCategoryIndexPath, categoryIndexPath == indexPath {
            
            selected = true
        }
        cell.configureCell(
            category: category,
            selected: selected
        )
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension CategorySelectorVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! DiscoverCategoryCell
        cell.toggleSelected(selected: !cell.categorySelected)
        
        if cell.categorySelected {
            
            selectedCategoryIndexPath = indexPath
            delegate?.categorySelected(category: cell.category)
        }
        else {
            
            selectedCategoryIndexPath = nil
            delegate?.categorySelected(category: nil)
        }
        collectionView.reloadData()
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension CategorySelectorVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 5.5
        
        let paddingSpace = browseCategoryCollectionViewSectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(
            width: widthPerItem,
            height: collectionView.frame.height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return browseCategoryCollectionViewSectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return browseCategoryCollectionViewSectionInsets.left
    }
}
