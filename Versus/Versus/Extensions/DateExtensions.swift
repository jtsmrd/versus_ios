//
//  DateExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

extension Date {
    
    var toISO8601String: String {
        return Formatter.iso8601.string(from: self)
    }
    
    /// Returns the amount of seconds until another date
    func seconds(until date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: self, to: date).second ?? 0
    }
}
