//
//  ShareIconCollection.swift
//  Versus
//
//  Created by JT Smrdel on 5/12/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum ShareIconType {
    case instagram
    case message
    case whatsApp
    case facebookMessenger
}

class ShareIconCollection {
    
    static let instance = ShareIconCollection()
    var shareIcons = [ShareIcon]()
    
    private init() {
        configureShareIcons()
    }
    
    private func configureShareIcons() {
        
        let instagramShareIcon = ShareIcon(id: 1, imageName: "instagram_icon", title: "Instagram", shareIconType: .instagram)
        let messageShareIcon = ShareIcon(id: 2, imageName: "message_icon", title: "Message", shareIconType: .message)
        let whatsappShareIcon = ShareIcon(id: 3, imageName: "whatsapp_icon", title: "WhatsApp", shareIconType: .whatsApp)
        let facebookMessengerShareIcon = ShareIcon(id: 4, imageName: "facebook_messenger_icon", title: "Messenger", shareIconType: .facebookMessenger)
        shareIcons.append(contentsOf: [instagramShareIcon, messageShareIcon, whatsappShareIcon, facebookMessengerShareIcon])
    }
}

struct ShareIcon {
    
    var id: Int
    var imageName: String
    var title: String
    var shareIconType: ShareIconType
}
