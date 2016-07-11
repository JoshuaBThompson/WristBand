//
//  Knob.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Knob: UIControl {
    //MARK: properties
    var instSnap: SnapFilter!
    var clickRingActive = true
    var clickActive = false
    var angle: CGFloat = 0.0
    var previousTimestamp = 0.0
    var rotDir: CGFloat = 1
    let angleUpdatePeriod = 0.025
    var previousLocation: CGPoint!
    let circleAngle: CGFloat = 360
    let innerKnobRadius: CGFloat = 70.0
    let detentCount = 18 //number of instruments
    let angleRangeEn = false //enforce angle range limits
    
    var absAngle: CGFloat {
        if(angle < 0){
            return circleAngle + angle //ex: 360 + (-90) = 270 deg
        }
        else{
            return angle
        }
    }
    
    var detent: Int {
        return instSnap.getDetent(absAngle)
    }
    
    
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawKnobCanvas(rotation: angle, clickSelected: clickActive, clickRingActive: clickRingActive)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("instrument snap")
        instSnap = SnapFilter(detentCount: detentCount, angleOffset: angle, angleRange: 360)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("instrument snap")
        instSnap = SnapFilter(detentCount: detentCount, angleOffset: angle, angleRange: 360)
        
    }
    
    //MARK: draw functions
    func turnKnob(){
        setNeedsDisplay()
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
        if(angleRangeEn){
            enforceAngleRange()
        }
        else if (abs(angle) > 360){
            self.angle = 0
        }
    }
    
    func enforceAngleRange(){
        if(angle < instSnap.minAngle){
            angle = instSnap.minAngle
        }
        else if(angle > instSnap.maxAngle){
            angle = instSnap.maxAngle
        }
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
            clickRingActive = true
            turnKnob()
            print("new angle \(angle)")
            print("abs angle \(absAngle)")
            sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        }
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        clickRingActive = true  //TODO: should we set back to false?
        setNeedsDisplay()
    }
    
    
}


/*
 Snap filter class
 Use this to create snap filter for various knob functions (instrument selection, tempo ...etc)
 */


class SnapFilter {
    
    var angles = [CGFloat]() //list of angles for each detent number
    var count: Int! //divide angle range by this number to get angle per detent
    var offset: CGFloat! //angle offset, where angles will start from
    var range: CGFloat! //for ex: 360 deg
    var apd: CGFloat! //angle per detent
    
    
    var maxAngle: CGFloat {
        return offset
    }
    
    var minAngle: CGFloat {
        return offset - range
    }
    //MARK: Initialize snap filter
    init(detentCount: Int, angleOffset: CGFloat, angleRange: CGFloat){
        count = detentCount
        offset = angleOffset
        range = angleRange
        
        //calculate angle per detents using count and range
        //ex: if range = 360 deg and count = 10 then angle per detent = 36 deg
        apd = abs(range / CGFloat(count))
    }
    
    //MARK: Initialize angle list
    func initAngles(){
        for i in 0..<count {
            let angle = offset + apd*CGFloat(i) //ex: 0 + 36*2 = 72 deg
            angles.append(angle)
        }
    }
    
    //MARK: Get detent from angle
    func getDetent(angle: CGFloat)->Int{
        let detent = abs(Int((angle-offset)/apd))
        return detent
        
    }
    
    //MARK: Get detent angle
    func getDetentAngle(detent: Int)->CGFloat{
        if(detent < angles.count){
            return angles[detent]
        }
        else{
            return 0
        }
    }
    
}
