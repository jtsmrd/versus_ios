//
//  EditImageVC.swift
//  Versus
//
//  Created by JT Smrdel on 5/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol EditImageVCDelegate {
    func imageCropped(image: UIImage)
}

class EditImageVC: UIViewController {

    @IBOutlet weak var carvingView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cropView: CropView!
    
    
    var cropImageType: CropImageType = .circle
    var imageToCrop: UIImage!
    var delegate: EditImageVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = imageToCrop
        cropView.cropImageType = cropImageType
    }

    func initData(imageToCrop image: UIImage, cropImageType: CropImageType, delegate: EditImageVCDelegate) {
        self.imageToCrop = image
        self.cropImageType = cropImageType
        self.delegate = delegate
    }
    
    
    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func chooseButtonAction() {
        cropImage()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func scaleImageAction(_ sender: UIPinchGestureRecognizer) {
        imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    
    
    @IBAction func moveImageAction(_ sender: UIPanGestureRecognizer) {
        imageView.transform = imageView.transform.translatedBy(x: sender.translation(in: imageView).x, y: sender.translation(in: imageView).y)
        sender.setTranslation(.zero, in: imageView)
    }
    
    
    private func cropImage() {
        
        var maskBounds = cropView.cropPath.bounds
        maskBounds = carvingView.convert(cropView.cropPath.bounds, from: cropView)
        maskBounds = maskBounds.applying(CGAffineTransform(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))

        let cropPath: UIBezierPath = cropView.cropPath
        cropPath.apply(CGAffineTransform(translationX: -cropPath.bounds.origin.x, y: -cropPath.bounds.origin.y))
        cropPath.apply(CGAffineTransform(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))
        
        UIGraphicsBeginImageContextWithOptions(carvingView.frame.size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        carvingView.layer.render(in: context)
        
        guard let viewImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        UIGraphicsEndImageContext()
        
        guard let viewCGImage = viewImage.cgImage else { return }
        
        guard let cropCGImage = viewCGImage.cropping(to: maskBounds) else { return }
        
        let cropImage = UIImage(cgImage: cropCGImage)
        
        UIGraphicsBeginImageContextWithOptions(maskBounds.size, false, UIScreen.main.scale)
        
        guard let context2 = UIGraphicsGetCurrentContext() else { return }
        
        let maskPath: UIBezierPath = cropPath.reversing()
        context2.addPath(maskPath.cgPath)
        context2.clip(using: .evenOdd)
        
        cropImage.draw(in: CGRect(origin: .zero, size: maskBounds.size))
        
        guard let clipImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        UIGraphicsEndImageContext()
        
        delegate.imageCropped(image: clipImage)
    }
}


extension EditImageVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
