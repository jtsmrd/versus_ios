//
//  OptionIconCollection.swift
//  Versus
//
//  Created by JT Smrdel on 5/12/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum OptionIconType {
    case share
    case copyLink
    case report
}

class OptionIconCollection {
    
    static let instance = OptionIconCollection()
    var optionIcons = [OptionIcon]()
    
    private init() {
        configureOptionIcons()
    }
    
    private func configureOptionIcons() {
        
        let shareOptionIcon = OptionIcon(id: 1, imageName: "Share", title: "Share", optionIconType: .share)
        let copyLinkOptionIcon = OptionIcon(id: 2, imageName: "link_icon", title: "Copy Link", optionIconType: .copyLink)
        let reportOptionIcon = OptionIcon(id: 3, imageName: "report_icon", title: "Report", optionIconType: .report)
        optionIcons.append(contentsOf: [shareOptionIcon, copyLinkOptionIcon, reportOptionIcon])
    }
}

struct OptionIcon {
    
    var id: Int
    var imageName: String
    var title: String
    var optionIconType: OptionIconType
}
