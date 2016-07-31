//
//  PopupBlur.swift
//  Groover
//
//  Created by Joshua Thompson on 7/30/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class PopupBlur: UIView {
    var popupPath: UIBezierPath!
    var blurEffect: UIBlurEffect!
    var blurView: UIVisualEffectView!
    var mask: CAShapeLayer!
    
    override func drawRect(rect: CGRect) {
        popupPath = UIBezierPath()
        initBlurEffect()
        UIGroover.drawPopupCanvas(popupPath)
        addPopupBlurMask()
        print("popup blur drawRect")
    }
    
    func updateState(){
        setNeedsDisplay()
        print("popup blur needs display")
    }
    
    //MARK: Blur functions
    
    func addPopupBlurMask(){
        
        mask = CAShapeLayer()
        mask.path = popupPath.CGPath
        blurView.layer.mask = mask
        
    }
    
    func initBlurEffect(){
        //Create the visual effect
        //You can choose between ExtraLight, Light and Dark
        blurEffect = UIBlurEffect(style: .Dark)
        
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        //AutoLayout code
        //Size
        blurView.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: bounds.width))
        blurView.addConstraint(NSLayoutConstraint(item: blurView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: bounds.height))
        //Center
        addConstraint(NSLayoutConstraint(item: blurView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: blurView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
}
