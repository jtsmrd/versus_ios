//
//  UIDeviceExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 12/21/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

extension UIDevice {
    
    var deviceSizeType: DeviceSizeType {
        
        if userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return .small
            case 1334:
                return .medium
            case 1792:
                return .large
            case 1920:
                return .large
            case 2436:
                return .large
            case 2688:
                return .large
            default:
                return .unknown
            }
        }
        return .unknown
    }
}
