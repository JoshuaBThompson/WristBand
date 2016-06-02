//
//  knob.swift
//  Drum Beats
//
//  Created by Alex Crane on 5/25/16.
//  Copyright © 2016 Alex Crane. All rights reserved.
//

import UIKit

//@IBDesignable
class Knob: UIControl {
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        KnobStyleKit.drawKnob()
    }
    
    func turnKnob(knobAngle knobAngle: CGFloat = 281, innerKnobAngle: CGFloat = 0){
        //KnobStyleKit.drawKnob(knobAngle: knobAngle, innerKnobAngle: innerKnobAngle)
        //KnobStyleKit.drawKnob()
        
    }
    
    
    /* Touch Tracking */
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("begin tracking knob")
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("continue tracking with touch")
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        print("end tracking with touch")
    }
 
}
