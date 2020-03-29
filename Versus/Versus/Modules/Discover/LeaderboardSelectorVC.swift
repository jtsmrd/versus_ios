//
//  LeaderboardSelectorVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/27/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class LeaderboardSelectorVC: UIViewController {

    @IBOutlet weak var leaderboardCollectionView: UICollectionView!
    
    private let leaderboardService = LeaderboardService.instance
    private let pendingImageOperations = ImageOperations()
    private let leaderboardCollectionViewSectionInsets = UIEdgeInsets(
        top: 0,
        left: 2,
        bottom: 0,
        right: 2
    )
    
    private var leaderboards = [Leaderboard]()
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboardCollectionView.register(
            UINib(nibName: LEADERBOARD_CELL, bundle: nil),
            forCellWithReuseIdentifier: LEADERBOARD_CELL
        )
        
        getLeaderboards()
    }
    
    
    private func getLeaderboards() {
        
        leaderboardService.getLeaderboards { [weak self] (leaderboards, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.leaderboards = leaderboards.sorted(
                    by: { $0.type.id < $1.type.id }
                )
                self.leaderboardCollectionView.reloadData()
            }
        }
    }
    
    
    private func showLeaderboard(leaderboard: Leaderboard) {
        
        let leaderboardVC = LeaderboardVC(leaderboard: leaderboard)
        leaderboardVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            leaderboardVC,
            animated: true
        )
    }
    
    
    func reloadData() {
        getLeaderboards()
    }
}


// MARK: - UICollectionViewDataSource
extension LeaderboardSelectorVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return leaderboards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LEADERBOARD_CELL,
            for: indexPath
        ) as! LeaderboardCell
        
        let leaderboard = leaderboards[indexPath.row]
        cell.configureCell(leaderboard: leaderboard)
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension LeaderboardSelectorVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let leaderboard = leaderboards[indexPath.row]
        showLeaderboard(leaderboard: leaderboard)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension LeaderboardSelectorVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 3
        
        let paddingSpace = leaderboardCollectionViewSectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(
            width: widthPerItem,
            height: collectionView.frame.height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return leaderboardCollectionViewSectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return leaderboardCollectionViewSectionInsets.left
    }
}
