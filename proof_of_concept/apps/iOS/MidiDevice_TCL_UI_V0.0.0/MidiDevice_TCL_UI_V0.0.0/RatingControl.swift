//
//  RatingControl.swift
//  MidiDevice_TCL_UI_V0.0.0
//
//  Created by Joshua Thompson on 6/4/16.
//  Copyright © 2016 Joshua Thompson. All rights reserved.
//

import UIKit

class RatingButton: UIButton {
    var angle: CGFloat = 0.0
}

//@IBDesignable
class RatingControl: UIControl {
    //MARK: properties
    var imageView: UIImageView!
    var knobAngle: CGFloat = 0
    var previousTimestamp = 0.0
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        drawKnob()
    }
    
    
    /* this should be used for live rendering when @IBDesignable is tagged to class
    override func prepareForInterfaceBuilder() {
        //code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
        addSubviews()
        
    }
    
    //subview
    func addSubviews(){
    }
    
    //MARK: initialization
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let drawingSize = Int(frame.size.height)
        let width = drawingSize
        return CGSize(width: width, height: drawingSize)
    }


    
    func drawKnob() {
        layer.borderWidth = 1
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        
        //// Image Declarations
        let knobRotatePng = UIImage(named: "knobRotate")!
        let knobBgPng = UIImage(named: "knobBg")!
        let knobRecessionPng = UIImage(named: "knobRecession")!
        let knobInnerPng = UIImage(named: "knobInner")!
        let frameSize = frame.size
        
        //// knobBg Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, frameSize.width/2.0, frameSize.height/2.0)
        knobBgPng.drawInRect(CGRectMake(-knobBgPng.size.width/2.0, -knobBgPng.size.height/2.0, knobBgPng.size.width, knobBgPng.size.height))
        CGContextRestoreGState(context)
        
        //// knobRotate Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, frameSize.width/2.0, frameSize.height/2.0)
        CGContextRotateCTM(context, -knobAngle * CGFloat(M_PI) / 180)
        
        CGContextSaveGState(context)
        knobRotatePng.drawInRect(CGRectMake(-knobRotatePng.size.width/2.0, -knobRotatePng.size.height/2.0, knobRotatePng.size.width, knobRotatePng.size.height))
        CGContextRestoreGState(context)
        
        //// knobRecession Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, frameSize.width/2.0, frameSize.height/2.0)
        knobRecessionPng.drawInRect(CGRectMake(-0.679*frameSize.width, -0.689*frameSize.height, knobRecessionPng.size.width, knobRecessionPng.size.height))
        CGContextRestoreGState(context)
        
        //// innerKnobBg Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, frameSize.width/2.0, frameSize.height/2.0)
        knobInnerPng.drawInRect(CGRectMake(-0.663*frameSize.width, -0.678*frameSize.height, knobInnerPng.size.width, knobInnerPng.size.height))
        CGContextRestoreGState(context)
        
        print("draw knob!")
        
    }
    
    
    func turnKnob(){
        setNeedsDisplay()
    }
    
    
    
    /* Touch Tracking */
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("begin tracking knob")
        previousTimestamp = event!.timestamp;
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("continue tracking with touch")
        var rightSide = false
        var bottomSide = false
        let location = touch.locationInView(self)
        let prevLocation = touch.previousLocationInView(self)
        let distanceFromPrevious = distanceBetweenPoints(location, prev: prevLocation)
        let timeSincePrevious = event!.timestamp - self.previousTimestamp
        
        previousTimestamp = event!.timestamp
        let xDist = distanceFromPrevious[0]
        let yDist = distanceFromPrevious[1]
        let maxDist = distanceFromPrevious[2]
        var speed = maxDist/CGFloat(timeSincePrevious)
        print("y \(location.y) and x: \(location.x)")
        if(location.x >= frame.size.width/2.0){
            print("right side")
            rightSide = true
        }
        else{
            if(abs(xDist) >= abs(yDist)){
                speed = speed * (-1)
            }
            rightSide = false
        }
        if(location.y <= frame.size.height/2.0){
            bottomSide = true
        }
        else{
            if(abs(xDist) >= abs(yDist)){
                speed = speed * (-1)
            }
            bottomSide = false
        }
        if(rightSide){
            if(speed >= 0){
                knobAngle -= 5
            }
            else{
                knobAngle += 5
                }
        }
        else {
            if(speed >= 0){
                knobAngle += 5
            }
            else{
                knobAngle -= 5
            }
        }
        if(knobAngle >= 360 || knobAngle <= -360){
            knobAngle = 0
        }
        
        turnKnob()
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        return true
    }
    
    func distanceBetweenPoints(loc: CGPoint, prev: CGPoint) -> Array<CGFloat>{
        let xtotal = CGFloat(loc.x - prev.x)
        let ytotal = CGFloat(loc.y - prev.y)
        var max: CGFloat!
        if(abs(xtotal) >= abs(ytotal)){
            max = xtotal
        }
        else{
        max = ytotal
        }
        return [xtotal, ytotal, max]
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        print("end tracking with touch")
    }


}
