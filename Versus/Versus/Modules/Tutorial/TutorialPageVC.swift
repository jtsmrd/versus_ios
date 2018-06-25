//
//  TutorialPageVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/24/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class TutorialPageVC: UIViewController {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tutorialImageView: UIImageView!
    @IBOutlet weak var tutorialLabel: UILabel!
    
    
    var backgroundImage: UIImage?
    var tutorialImage: UIImage?
    var tutorialText: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        
        backgroundImageView.image = backgroundImage
        tutorialImageView.image = tutorialImage
        tutorialLabel.text = tutorialText
    }

    
    func initData(backgroundImage: UIImage?, tutorialImage: UIImage?, tutorialText: String) {
        self.backgroundImage = backgroundImage
        self.tutorialImage = tutorialImage
        self.tutorialText = tutorialText
    }
}
