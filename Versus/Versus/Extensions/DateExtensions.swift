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
    
    var toElapsedTimeString_Minimal: String {
                
        if let numberOfDaysSince = Calendar.current.dateComponents([.day], from: self, to: Date()).day, numberOfDaysSince > 7 {
            return String(format: "%iw", numberOfDaysSince / 7)
        }
        else if let numberOfDaysSince = Calendar.current.dateComponents([.day], from: self, to: Date()).day, numberOfDaysSince > 0 && numberOfDaysSince < 7 {
            return String(format: "%id", numberOfDaysSince)
        }
        else if let numberOfHoursSince = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour, numberOfHoursSince > 0 {
            return String(format: "%ih", numberOfHoursSince)
        }
        else if let numberOfMinutesSince = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute, numberOfMinutesSince > 0 {
            return String(format: "%im", numberOfMinutesSince)
        }
        else if let numberOfSecondsSince = Calendar.current.dateComponents([.second], from: self, to: Date()).second, numberOfSecondsSince > 0 {
            return String(format: "%is", numberOfSecondsSince)
        }
        return "Just now"
    }
    
    /// Returns the amount of seconds until another date
    func seconds(until date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: self, to: date).second ?? 0
    }
}
