//
//  CompetitionSubmittedVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionSubmittedVC: UIViewController {

    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func tabkeMeHomeButtonAction() {
        
        // Dismiss the competition entry view controller stack.
        navigationController?.dismiss(
            animated: true,
            completion: nil
        )
    }
}
