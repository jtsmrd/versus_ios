//
//  Endpoints.swift
//  Versus
//
//  Created by JT Smrdel on 12/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

struct Endpoints {
 
    static let BASE_URL = "http://192.168.1.7/versus/v1/"
    
    private static let COMPETITION_ENTRY = BASE_URL + "competitionEntry"
    private static let GET_UNMATCHED_COMPETITION_ENTRIES = COMPETITION_ENTRY + "?id=%@"
    static let INSERT_COMPETITION_ENTRY = COMPETITION_ENTRY
    
    static func getUnmatchedCompetitionEntries(userId: String) -> String {
        return String(format: GET_UNMATCHED_COMPETITION_ENTRIES, userId)
    }
}
