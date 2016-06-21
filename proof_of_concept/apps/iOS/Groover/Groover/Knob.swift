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
    var innerKnobActive = false
    var clickActive = false
    var angle: CGFloat = 0.0
    var previousTimestamp = 0.0
    var rotDir: CGFloat = 1
    let angleUpdatePeriod = 0.025
    var previousLocation: CGPoint!
    let circleAngle: Int = 360
    let innerKnobRadius: CGFloat = 70.0
    var _divider: CGFloat = 1
    var divider: CGFloat {
        if(_divider <= 0){
            _divider = 1
        }
        return _divider
    }
    var detentNum: Int {
        let detent = Int(CGFloat(angle)/divider)
        if(detent > 0){
            //for ex: if angle = 2.4 then return 360 - abs Int(2.4/1) = 360 - 2 = 358 deg
            return circleAngle - detent
        }
        else{
            //for ex: if angle = -2.4 then return abs Int(-2.4/1) = 2 deg
            return abs(detent)
        }
        
    }
    
    
    
    override func drawRect(rect: CGRect) {
        GrooverUI.drawKnobCanvas(knobAngle: angle, innerKnobActive: innerKnobActive, clickActive: clickActive, innerKnobPosition: angle)
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
    
    //MARK: set params
    func setDivider(num: CGFloat){
        if(num > 0){
            _divider = num
        }
    }
    
    //MARK: get distance from center of knob and see if within inner knob
    func isWithinInnerKnob(loc: CGPoint)->Bool{
        let dx = loc.x - frame.size.width/2.0
        let dy = loc.y - frame.size.height/2.0
        
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        return distance <= innerKnobRadius
    }
    
    //MARK: get angle displaced function (degrees)
    func getAngleChangeFromPositionChange(currentLoc: CGPoint, prevLoc: CGPoint) -> CGFloat{
        //cosin(deltaAngle) = r1*r2/||r1||*||r2|| --- where currentLoc = r2 and prevLoc = r1
        //so deltaAngle = arccosin( r1 * r2 / ||r1|| * ||r2|| )
        let r1 = [prevLoc.x - frame.size.width/2.0, prevLoc.y - frame.size.height/2.0]
        let r2 = [currentLoc.x - frame.size.width/2.0, currentLoc.y - frame.size.height/2.0]
        let r1r2 = (r1[0] * r2[0]) + (r1[1] * r2[1])
        let r1s = sqrt((r1[0] * r1[0]) + (r1[1] * r1[1]))
        let r2s = sqrt((r2[0] * r2[0]) + (r2[1] * r2[1]))
        var deltaAngleRad: CGFloat = 0.0
        if(r1s*r2s != 0.0 && r1r2/(r1s*r2s) <= 1.0){
            //make sure don't divide by zero
            print("acos \(r1r2/(r1s*r2s))")
            deltaAngleRad = acos(r1r2/(r1s*r2s))
        }
        else{
            //if divide by zero then just set angle to 0 radians
            deltaAngleRad = 0.0
        }
        let degPerRad = CGFloat(180.0/M_PI)
        
        let deltaAngleDeg = deltaAngleRad*degPerRad //convert radians to degrees
        return deltaAngleDeg
    }
    
    func incrementAngle(deltaAngle: CGFloat){
        angle += deltaAngle
        if(abs(angle) > 360){angle = 0}
    }
    
    func updateRotDirection(currentLoc: CGPoint, prevLoc: CGPoint){
        //direction = sign of unit angular momentum (L) resulting from cross product of velocity x r
        //velcity = r2 - r1 (current - prev location vector)
        //r = r1 (prev location)
        //L = V x R = Vx*Ryk - Vy*Rxk
        let r1 = [prevLoc.x - frame.size.width/2.0, prevLoc.y - frame.size.height/2.0] // Rx , Ry
        let r2 = [currentLoc.x - frame.size.width/2.0, currentLoc.y - frame.size.height/2.0]
        let v = [r2[0] - r1[0], r2[1] - r1[1]] // Vx , Vy
        let r = r1
        let l = v[0]*r[1] - v[1]*r[0] //angular momentum vector k with sign direction
        
        if(l > 0){
            rotDir = 1
        }
        else if(l < 0){
            rotDir = -1
        }
        else{
            rotDir = 0
        }
        
        
    }
    
    //MARK: touch tracking functions
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousTimestamp = event!.timestamp //need initial timestamp for continue tracking with touch calculations
        previousLocation = touch.previousLocationInView(self)
        print("started touch at x \(previousLocation.x) and y \(previousLocation.y)")
        if(isWithinInnerKnob(previousLocation)){
            clickActive = !clickActive
            sendActionsForControlEvents(.EditingChanged)
            setNeedsDisplay()
        }
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        print("continue tracking with touch")
        
        let timeSincePrevious = event!.timestamp - previousTimestamp
        
        //only calc angle after 1 sec since delta angles are too small if calc every time continue tracking is called
        if(timeSincePrevious >= angleUpdatePeriod){
            let location = touch.locationInView(self)
            let dltaAngle = getAngleChangeFromPositionChange(location, prevLoc: previousLocation)
            updateRotDirection(location, prevLoc: previousLocation)
            
            previousLocation = location //update prev loc
            previousTimestamp = event!.timestamp //update prev timestamp
            print("delta angle is \(dltaAngle)")
            
            incrementAngle(rotDir*dltaAngle)
            innerKnobActive = true
            turnKnob()
            print("new angle \(angle)")
            sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        }
       
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        innerKnobActive = false
        setNeedsDisplay()
    }
    
    
    
}
