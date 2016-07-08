//
//  popup.swift
//  Groover
//
//  Created by Alex Crane on 6/27/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit



@IBDesignable
class Popup: UIView {
    var popupPath: UIBezierPath!
    var blurEffect: UIBlurEffect!
    var blurView: UIVisualEffectView!
    var mask: CAShapeLayer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //popupPath = UIBezierPath()
        //initBlurEffect()
        //drawPopupCanvas()
        //addPopupBlurMask()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //popupPath = UIBezierPath()
        //initBlurEffect()
        //drawPopupCanvas()
        //addPopupBlurMask()
        
    }
    
    override func drawRect(rect: CGRect) {
        
        //GrooverUI.drawPopupCanvas()
        //drawPopupCanvas()
    }
    
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
    
    func drawPopupCanvas(){
        
        popupPath.moveToPoint(CGPointMake(36.27, 302))
        popupPath.addLineToPoint(CGPointMake(59.54, 302))
        popupPath.addLineToPoint(CGPointMake(71.33, 313.79))
        popupPath.addCurveToPoint(CGPointMake(75.58, 313.79), controlPoint1: CGPointMake(72.5, 314.96), controlPoint2: CGPointMake(74.41, 314.96))
        popupPath.addLineToPoint(CGPointMake(87.37, 302))
        popupPath.addLineToPoint(CGPointMake(87.37, 302))
        popupPath.addLineToPoint(CGPointMake(187.18, 302))
        popupPath.addLineToPoint(CGPointMake(297.01, 302))
        popupPath.addCurveToPoint(CGPointMake(300, 299), controlPoint1: CGPointMake(298.66, 302), controlPoint2: CGPointMake(300, 300.66))
        popupPath.addLineToPoint(CGPointMake(300, 3))
        popupPath.addCurveToPoint(CGPointMake(297.01, 0), controlPoint1: CGPointMake(300, 1.35), controlPoint2: CGPointMake(298.66, 0))
        popupPath.addLineToPoint(CGPointMake(2.99, 0))
        popupPath.addCurveToPoint(CGPointMake(0, 3), controlPoint1: CGPointMake(1.34, 0), controlPoint2: CGPointMake(0, 1.34))
        popupPath.addLineToPoint(CGPointMake(0, 299))
        popupPath.addCurveToPoint(CGPointMake(2.99, 302), controlPoint1: CGPointMake(0, 300.65), controlPoint2: CGPointMake(1.34, 302))
        popupPath.addLineToPoint(CGPointMake(36.27, 302))
        popupPath.closePath()
        popupPath.usesEvenOddFillRule = true;
        
    }
  
    
    
    
}
