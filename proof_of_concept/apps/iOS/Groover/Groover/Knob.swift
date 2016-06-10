//
//  Knob.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Knob: UIControl {
    //MARK: properties
    var angle: CGFloat = 0.0
    var previousTimestamp = 0.0
    var initialLocation: CGPoint!
    
    
    
    override func drawRect(rect: CGRect) {
        GrooverUI.drawKnobCanvas(knobAngle: angle)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    //MARK: draw functions
    func turnKnob(){
        setNeedsDisplay()
    }
    
    //MARK: touch tracking functions
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("beging tracking knob with touch")
        previousTimestamp = event!.timestamp //need initial timestamp for continue tracking with touch calculations
        initialLocation = touch.locationInView(self)
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("continue tracking with touch")
        let location = touch.locationInView(self)
        let prevLocation = touch.previousLocationInView(self)
        
        let timeSincePrevious = event!.timestamp - self.previousTimestamp
        
        turnKnob()
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        print("end tracking with touch")
    }
    
}
