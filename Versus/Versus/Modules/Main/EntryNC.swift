//
//  EntryNC.swift
//  Versus
//
//  Created by JT Smrdel on 2/22/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class EntryNC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let competitionEntryStoryboard = UIStoryboard(
            name: ENTRY,
            bundle: nil
        )
        let vc = competitionEntryStoryboard.instantiateViewController(
            withIdentifier: SELECT_COMPETITION_MEDIA_VC
        ) as! SelectCompetitionMediaVC
        
        // Use full screen for capturing media.
        vc.videoGravity = .resizeAspectFill
        
        // Set max video duration to 60 seconds.
        vc.maximumVideoDuration = 60.0
        
        vc.loadViewIfNeeded()
        addChild(vc)
        
        isNavigationBarHidden = true
    }
}
