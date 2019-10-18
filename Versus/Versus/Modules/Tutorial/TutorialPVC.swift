//
//  TutorialPVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/24/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol TutorialPVCPageTransitionDelegate {
    func tutorialTransitionedTo(index pageIndex: Int)
}

class TutorialPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    var tutorialViewControllers: [UIViewController]!
    var pageTransitionDelegate: TutorialPVCPageTransitionDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTutorialViewControllers()
        dataSource = self
        delegate = self
        setViewControllers([tutorialViewControllers.first!], direction: .forward, animated: true, completion: nil)
    }

    
    private func configureTutorialViewControllers() {
        
        let tutorialStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let backgroundImage = UIImage(named: "")
        
        let firstTutorialText = "Versus is the first competition app that brings talent from all over the world together face-to-face on your phone."
        let secondTutorialText = "Record your talent and share it with the world, while growing your fan base and competing against other users."
        let thirdTutorialText = "Vote between the best of the best to help users rank up and become the biggest stars on social media."
        
        let firstTutorialImage = UIImage(named: "Tutorial_Page_1")
        let secondTutorialImage = UIImage(named: "Tutorial_Page_2")
        let thirdTutorialImage = UIImage(named: "Tutorial_Page_3")
        
        let firstTutorialPage = tutorialStoryboard.instantiateViewController(withIdentifier: "TutorialPageVC") as! TutorialPageVC
        firstTutorialPage.initData(backgroundImage: backgroundImage, tutorialImage: firstTutorialImage, tutorialText: firstTutorialText)
        
        let secondTutorialPage = tutorialStoryboard.instantiateViewController(withIdentifier: "TutorialPageVC") as! TutorialPageVC
        secondTutorialPage.initData(backgroundImage: backgroundImage, tutorialImage: secondTutorialImage, tutorialText: secondTutorialText)
        
        let thirdTutorialPage = tutorialStoryboard.instantiateViewController(withIdentifier: "TutorialPageVC") as! TutorialPageVC
        thirdTutorialPage.initData(backgroundImage: backgroundImage, tutorialImage: thirdTutorialImage, tutorialText: thirdTutorialText)
        
        tutorialViewControllers = [firstTutorialPage, secondTutorialPage, thirdTutorialPage]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = tutorialViewControllers.firstIndex(of: viewController) else { return nil }
        if pageIndex > 0 {
            return tutorialViewControllers[pageIndex - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = tutorialViewControllers.firstIndex(of: viewController) else { return nil }
        if pageIndex < tutorialViewControllers.count - 1 {
            return tutorialViewControllers[pageIndex + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers.first {
            if let index = tutorialViewControllers.firstIndex(of: viewController) {
                pageTransitionDelegate.tutorialTransitionedTo(index: index)
            }
        }
    }
}
