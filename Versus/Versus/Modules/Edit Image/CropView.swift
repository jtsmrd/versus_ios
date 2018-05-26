//
//  CropView.swift
//  Versus
//
//  Created by JT Smrdel on 5/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum CropImageType {
    case circle
    case landscape
    case square
}

class CropView: UIView {

    var cropImageType: CropImageType = .circle
    var cropPath: UIBezierPath!
    
    
    override func draw(_ rect: CGRect) {
        drawCropShape()
    }
    
    
    private func drawCropShape() {
        
        let mainPath = UIBezierPath()
        
        mainPath.append(UIBezierPath(rect: frame))
        
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).set()
        
        switch cropImageType {
        case .circle:
            cropPath = circlePath()
        case .landscape:
            cropPath = landscapePath()
        case .square:
            cropPath = squarePath()
        }
        mainPath.append(cropPath)
        
        mainPath.usesEvenOddFillRule = true
        #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5).set()
        mainPath.fill()
    }
    
    
    private func circlePath() -> UIBezierPath {
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: frame.width, height: frame.width)))
        circlePath.apply(CGAffineTransform(translationX: 0.0, y: (frame.height - circlePath.bounds.height) / 2))
        return circlePath
    }
    
    
    private func landscapePath() -> UIBezierPath {
        let landscapePath = UIBezierPath(rect: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: frame.width, height: frame.width * (7 / 25))))
        landscapePath.apply(CGAffineTransform(translationX: 0.0, y: (frame.height - landscapePath.bounds.height) / 2))
        return landscapePath
    }
    
    
    private func squarePath() -> UIBezierPath {
        let squarePath = UIBezierPath(rect: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: frame.width, height: frame.width)))
        squarePath.apply(CGAffineTransform(translationX: 0.0, y: (frame.height - squarePath.bounds.height) / 2))
        return squarePath
    }
}
