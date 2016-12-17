//
//  KnobCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/24/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class KnobCtrl: Knob {
    
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
    let detentCount = 12 //number of instruments / presets
    let angleRangeEn = false //enforce angle range limits
    let angleRate: CGFloat = 0.5 // if set to 1 then knob turns with user finger at same speed
    
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
    
    var drawAngle: CGFloat {
        return -angle
    }
    
    
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawKnobCanvas(knobFrame: self.bounds, rotation: drawAngle, clickSelected: clickActive, clickRingActive: clickRingActive)
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
    func isWithinInnerKnob(_ loc: CGPoint)->Bool{
        let dx = loc.x - frame.size.width/2.0
        let dy = loc.y - frame.size.height/2.0
        
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        return distance <= innerKnobRadius
    }
    
    //MARK: get angle displaced function (degrees)
    func getAngleChangeFromPositionChange(_ currentLoc: CGPoint, prevLoc: CGPoint) -> CGFloat{
        //cosin(deltaAngle) = r1*r2/||r1||*||r2|| --- where currentLoc = r2 and prevLoc = r1
        //so deltaAngle = arccosin( r1 * r2 / ||r1|| * ||r2|| )
        let r1 = [prevLoc.x - frame.size.width/2.0, -(prevLoc.y - frame.size.height/2.0)] //-y to fix iOS weird coords
        let r2 = [currentLoc.x - frame.size.width/2.0, -(currentLoc.y - frame.size.height/2.0)] //-y to fix iOS weird coords
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
    
    func incrementAngle(_ deltaAngle: CGFloat){
        angle += angleRate*deltaAngle
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
    
    func updateRotDirection(_ currentLoc: CGPoint, prevLoc: CGPoint){
        //direction = sign of unit angular momentum (L) resulting from cross product of velocity x r
        //velcity = r2 - r1 (current - prev location vector)
        //r = r1 (prev location)
        //L = V x R = Vx*Ryk - Vy*Rxk
        let r1 = [prevLoc.x - frame.size.width/2.0, -(prevLoc.y - frame.size.height/2.0)] // Rx , Ry
        let r2 = [currentLoc.x - frame.size.width/2.0, -(currentLoc.y - frame.size.height/2.0)]
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
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousTimestamp = event!.timestamp //need initial timestamp for continue tracking with touch calculations
        previousLocation = touch.previousLocation(in: self)
        print("started touch at x \(previousLocation.x) and y \(previousLocation.y)")
        if(isWithinInnerKnob(previousLocation)){
            clickActive = !clickActive
            sendActions(for: .editingChanged)
            setNeedsDisplay()
        }
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        print("continue tracking with touch")
        
        let timeSincePrevious = event!.timestamp - previousTimestamp
        
        //only calc angle after 1 sec since delta angles are too small if calc every time continue tracking is called
        if(timeSincePrevious >= angleUpdatePeriod){
            let location = touch.location(in: self)
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
            sendActions(for: .valueChanged) //this tells view controller that something changed
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        clickRingActive = true  //TODO: should we set back to false?
        setNeedsDisplay()
        sendActions(for: .editingDidEnd)
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
        initAngles()
    }
    
    //MARK: Initialize angle list
    func initAngles(){
        for i in 0..<count {
            let angle = offset + apd*CGFloat(i) //ex: 0 + 36*2 = 72 deg
            angles.append(angle)
        }
    }
    
    //MARK: Get detent from angle
    func getDetent(_ angle: CGFloat)->Int{
        let detent = abs(Int((angle-offset)/apd))
        return detent
        
    }
    
    //MARK: Get detent angle
    func getDetentAngle(_ detent: Int)->CGFloat{
        if(detent < angles.count){
            return angles[detent]
        }
        else{
            return 0
        }
    }
    
}

