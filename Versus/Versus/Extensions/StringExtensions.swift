//
//  StringExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/15/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

extension String {
    
    // To check text field or String is blank or not
    var isBlank: Bool {
        get {
            return trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }
    }
    
    // Validate email
    var isValidEmail: Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        }
        catch {
            return false
        }
    }
    
    // Validate phone number
    var isValidPhoneNumber: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\A[0-9]{10}\\z", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        }
        catch { }
        return false
    }
    
    // Validate password
    var isValidPassword: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        }
        catch { }
        return false
    }
    
    // Get date from ISO8601 string
    // Example: "Mar 22, 2017, 10:22 AM"
    var toISO8601Date: Date {
        
        let defaultDate = Date(timeIntervalSince1970: 0)
        
        // Replace '+' with '.' - occurs with php iso8601 date string
        let formattedDateString = self.replacingOccurrences(of: "+", with: ".")
        
        let convertedDate = Formatter.iso8601.date(from: formattedDateString)
        
        return convertedDate ?? defaultDate
    }
    
    
    /// Used to format usernames
    var withAtSignPrefix: String {
        
        var newString = self
        newString.insert("@", at: self.startIndex)
        return newString
    }
}
