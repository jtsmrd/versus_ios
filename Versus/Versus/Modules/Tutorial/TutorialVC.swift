//
//  TutorialVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/24/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class TutorialVC: UIViewController, TutorialPVCPageTransitionDelegate {

    @IBOutlet weak var tutorialPageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func launchButtonAction() {
        CurrentUser.tutorialDisplayed = true
        appDelegate.showInitialView(nil)
    }
    
    
    func tutorialTransitionedTo(index pageIndex: Int) {
        tutorialPageControl.currentPage = pageIndex
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPVC = segue.destination as? TutorialPVC {
            tutorialPVC.pageTransitionDelegate = self
            addChildViewController(segue.destination)
        }
    }
}
