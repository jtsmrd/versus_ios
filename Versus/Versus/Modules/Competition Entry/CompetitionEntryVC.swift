//
//  CompetitionEntryVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionEntryVC: UIViewController {

    
    @IBOutlet weak var recordUploadSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Unwind segue
    @IBAction func unwindFromCompetitionSubmit(segue: UIStoryboardSegue) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonAction() {
        performSegue(withIdentifier: SHOW_COMPETITION_DETAILS, sender: nil)
    }
    
    
    
    @IBAction func recordUploadSegmentedControlAction() {
        
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
