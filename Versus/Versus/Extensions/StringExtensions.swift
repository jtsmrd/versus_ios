//
//  StringExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/15/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

extension String {
    
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            return trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }
    }
    
    //Validate email
    var isValidEmail: Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        }
        catch {
            return false
        }
    }
    
    //Validate phone number
    var isValidPhoneNumber: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\A[0-9]{10}\\z", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        }
        catch { }
        return false
    }
    
    //Validate password
    var isValidPassword: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        }
        catch { }
        return false
    }
}
