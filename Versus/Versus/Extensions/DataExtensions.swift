//
//  DataExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 12/27/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

extension Data {
    
    
    /// Returns the size of the data in megabytes.
    var megabyteCount: String {
        
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useMB]
        byteCountFormatter.countStyle = .file
        
        let count: String = byteCountFormatter.string(fromByteCount: Int64(self.count))
        
        return count
    }
}
