//
//  CategoryCollection.swift
//  Versus
//
//  Created by JT Smrdel on 4/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CategoryCollection {
    
    static let instance = CategoryCollection()
    var categories = [Category]()
    
    private init() {
        configureCategories()
    }
    
    private func configureCategories() {
        
        let category1 = Category(categoryType: .mic, title: "Mic", iconName: "Mic", backgroundColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        let category2 = Category(categoryType: .sports, title: "Sports", iconName: "Sports", backgroundColor: #colorLiteral(red: 0.919831718, green: 0.9066269966, blue: 0.005809288197, alpha: 1))
        let category3 = Category(categoryType: .comedy, title: "Comedy", iconName: "Comedy", backgroundColor: #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1))
        let category4 = Category(categoryType: .food, title: "Food", iconName: "Food", backgroundColor: #colorLiteral(red: 0, green: 0.6342382715, blue: 0.01451354011, alpha: 1))
        let category5 = Category(categoryType: .dance, title: "Dance", iconName: "Dance_V2", backgroundColor: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1))
        let category6 = Category(categoryType: .art, title: "Art", iconName: "Art_V1", backgroundColor: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1))
        let category7 = Category(categoryType: .fashion, title: "Fashion", iconName: "Fashion", backgroundColor: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        categories.append(contentsOf: [category1, category2, category3, category4, category5, category6, category7])
    }
    
    func categoryIconFor(categoryTypeId: Int) -> UIImage? {
        if let category = categories.first(where: {$0.categoryType.rawValue == categoryTypeId }) {
            return UIImage(named: category.iconName)
        }
        return nil
    }
    
    func categoryColorFor(categoryTypeId: Int) -> UIColor {
        return categories.first(where: {$0.categoryType.rawValue == categoryTypeId })!.backgroundColor
    }
}

enum CategoryType: Int {
    case mic = 1
    case sports = 2
    case comedy = 3
    case food = 4
    case dance = 5
    case art = 6
    case fashion = 7
}

struct Category {
    var categoryType: CategoryType
    var title: String
    var iconName: String
    var backgroundColor: UIColor
}

