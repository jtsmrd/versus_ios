//
//  ViewCompetitionOptionsVC.swift
//  Versus
//
//  Created by JT Smrdel on 8/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol ViewCompetitionOptionsVCDelegate {
    func dismissOptionsView()
}

class ViewCompetitionOptionsVC: UIViewController {

    private let shareIconCollection = ShareIconCollection.instance
    private let optionIconCollection = OptionIconCollection.instance
    
    @IBOutlet weak var shareCollectionView: UICollectionView!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    
    private var delegate: ViewCompetitionOptionsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    func initData(delegate: ViewCompetitionOptionsVCDelegate) {
        self.delegate = delegate
    }
    
    
    /**
     
     */
    @IBAction func cancelButtonAction() {
        delegate?.dismissOptionsView()
    }
    
    
    /**
     
     */
    private func shareToInstagramAction() {
        displayMessage(message: "Share to Instagram")
    }
    
    
    /**
     
     */
    private func shareToMessageAction() {
        displayMessage(message: "Share to Message")
    }
    
    
    /**
     
     */
    private func shareToWhatsAppAction() {
        displayMessage(message: "Share to WhatsApp")
    }
    
    
    /**
     
     */
    private func shareToFacebookMessengerAction() {
        displayMessage(message: "Share to Facebook Messenger")
    }
    
    
    /**
     
     */
    private func optionShareAction() {
        displayMessage(message: "Share")
    }
    
    
    /**
     
     */
    private func optionCopyLinkAction() {
        displayMessage(message: "Copy Link")
    }
    
    
    /**
     
     */
    private func optionReportAction() {
        displayMessage(message: "Report Competition")
    }
}

extension ViewCompetitionOptionsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == shareCollectionView {
            return shareIconCollection.shareIcons.count
        }
        else if collectionView == optionsCollectionView {
            return optionIconCollection.optionIcons.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == shareCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COMPETITION_SHARE_CELL, for: indexPath) as? CompetitionShareCell {
                cell.configureCell(shareIcon: shareIconCollection.shareIcons[indexPath.row])
                return cell
            }
            return CompetitionShareCell()
        }
        else if collectionView == optionsCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COMPETITION_OPTION_CELL, for: indexPath) as? CompetitionOptionCell {
                cell.configureCell(optionIcon: optionIconCollection.optionIcons[indexPath.row])
                return cell
            }
            return CompetitionOptionCell()
        }
        return UICollectionViewCell()
    }
}

extension ViewCompetitionOptionsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == shareCollectionView {
            
            let shareIcon = shareIconCollection.shareIcons[indexPath.row]
            
            switch shareIcon.shareIconType {
            case .instagram:
                shareToInstagramAction()
            case .message:
                shareToMessageAction()
            case .whatsApp:
                shareToWhatsAppAction()
            case .facebookMessenger:
                shareToFacebookMessengerAction()
            }
        }
        else if collectionView == optionsCollectionView {
            
            let optionIcon = optionIconCollection.optionIcons[indexPath.row]
            
            switch optionIcon.optionIconType {
            case .share:
                optionShareAction()
            case .copyLink:
                optionCopyLinkAction()
            case .report:
                optionReportAction()
            }
        }
    }
}
