//
//  FollowSuggestionsVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/7/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowSuggestionsVC: UIViewController {

    @IBOutlet weak var followSuggestionsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func skipButtonAction() {
        performSegue(withIdentifier: SHOW_MAIN_STORYBOARD, sender: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
