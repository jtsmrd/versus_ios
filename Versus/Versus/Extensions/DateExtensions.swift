//
//  DateExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

extension Date {
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
