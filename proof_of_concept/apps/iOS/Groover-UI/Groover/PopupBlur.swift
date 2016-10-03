//
//  PopupBlur.swift
//  Groover
//
//  Created by Joshua Thompson on 7/30/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class PopupBlur: PopupCtrl {
    var popupPath: UIBezierPath!
    var blurEffect: UIBlurEffect!
    var blurView: UIVisualEffectView!
    var popupMask: CAShapeLayer!
    
    override func draw(_ rect: CGRect) {
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
        
        popupMask = CAShapeLayer()
        popupMask.path = popupPath.cgPath
        blurView.layer.mask = popupMask
        self.sendSubview(toBack: blurView)
        
        
    }
    
    func initBlurEffect(){
        //Create the visual effect
        //You can choose between ExtraLight, Light and Dark
        blurEffect = UIBlurEffect(style: .dark)
        
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        //AutoLayout code
        //Size
        blurView.addConstraint(NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: bounds.width))
        blurView.addConstraint(NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: bounds.height))
        //Center
        addConstraint(NSLayoutConstraint(item: blurView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: blurView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
    }
    
}
