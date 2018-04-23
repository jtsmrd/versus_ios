//
//  CompetitionEntry.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum CompetitionType: Int {
    case image = 1
    case video = 2
}

class CompetitionEntry {
    
    var awsCompetitionEntry: AWSCompetitionEntry!
    
    init(awsCompetitionEntry: AWSCompetitionEntry) {
        self.awsCompetitionEntry = awsCompetitionEntry
    }
}
