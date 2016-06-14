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
    var rotDir: CGFloat = 1
    let angleUpdatePeriod = 0.025
    var previousLocation: CGPoint!
    
    
    
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
            turnKnob()
            print("new angle \(angle)")
            sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        }
       
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
    }
    
}
