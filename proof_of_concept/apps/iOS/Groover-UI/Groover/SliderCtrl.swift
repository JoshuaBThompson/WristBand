//
//  SliderCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/14/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class SliderCtrl: UIControl{
    
    //MARK: Properties
    var max_value: Int = 200
    var min_value: Int = 1
    var default_value: Int = 60
    
    var previousLocation: CGPoint!
    var previousTimestamp = 0.0
    var minPosUpdateTime = 0.025 //25ms
    var maxPosX: CGFloat = 95
    var minPosX: CGFloat = -95.0
    var position: CGPoint!
    var snapFilter = SliderSnapFilter()
    
    //MARK: Computed properties
    var pos_to_value_scale: CGFloat {
        return CGFloat(self.max_value - self.min_value)/(self.maxPosX - self.minPosX)
    }
    
    var value_offset: CGFloat {
        /*
         y = mx + b -> t = m*p + offset
         offset = t - m*p when t = 1 p = 5
         offset = t - m*5
         m = max_temp - min_temp / maxPos - minPos
         */
        let offset = CGFloat(self.min_value) - (self.pos_to_value_scale*self.minPosX)
        return offset
    }
    
    var pos_offset: CGFloat {
        /*
         y = mx + b -> p = m*t + offset
         offset = p - m*t when p = 5 t = 1
         offset = p - m*1
         m = max_pos - min_pos / max_tempo - min_tempo
         */
        let offset = self.minPosX - (CGFloat(self.min_value)/(self.pos_to_value_scale))
        return offset
    }
    
    var detent: Int {
        return snapFilter.getDetent(self.position.x)
    }
    
    var scaled_detent: CGFloat {
        return snapFilter.getScaledDetent(self.position.x)
    }
    
    var pos_from_detent: CGFloat {
        let d = self.detent
        return self.snapFilter.getDetentPos(d)
    }
    
    //MARK: Update position x from value
    func update_pos_from_value(new_value: Int){
        if(self.position == nil){
            self.position = CGPoint(x: 0, y: 0)
        }
        var new_pos = CGFloat(new_value) * (self.maxPosX - self.minPosX) / CGFloat(self.max_value - self.min_value)
        new_pos = new_pos + self.pos_offset
        self.position.x = new_pos
    }
    
    //MARK: Update current position x from detent value
    func update_pos_from_detent(new_detent: Int){
        if(self.position == nil){
            self.position = CGPoint(x: 0, y: 0)
        }
        
        var new_pos = self.snapFilter.getDetentPos(new_detent)
        if(new_pos >= self.maxPosX){
            new_pos = self.maxPosX
        }
        else if(new_pos < self.minPosX){
            new_pos = self.minPosX
        }
        self.position.x = new_pos
    }
    
    //MARK: touch tracking functions
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        self.previousTimestamp = event!.timestamp //need initial timestamp for continue tracking with touch calculations
        self.previousLocation = touch.previousLocation(in: self)
        updateBeginPosition(self.previousLocation)
        print("begin tracking pan at \(self.previousLocation.x)")
        
        setNeedsDisplay()
        sendActions(for: .valueChanged) //this tells view controller that something changed
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        let timeSincePrevious = event!.timestamp - previousTimestamp
        
        //only calc angle after 1 sec since delta angles are too small if calc every time continue tracking is called
        if(timeSincePrevious >= self.minPosUpdateTime){
            let location = touch.location(in: self)
            updatePosition(location, prevLoc: self.previousLocation)
            self.previousTimestamp = event!.timestamp //update prev timestamp
            print("continue tracking pan with touch at \(location.x)")
            setNeedsDisplay()
            sendActions(for: .valueChanged) //this tells view controller that something changed
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let endLocation = touch?.location(in: self)
        print("end tracking pan at \(endLocation?.x)")
        let final_pos_x = self.pos_from_detent //snap to neartest detent
        self.position.x = final_pos_x
        setNeedsDisplay()
        sendActions(for: .valueChanged)
    }
    
    //MARK: Position calculation methods
    func updatePosition(_ currentLoc: CGPoint, prevLoc: CGPoint){
        let diff = currentLoc.x - self.previousLocation.x
        
        self.previousLocation = currentLoc //update prev loc
        
        if(self.position == nil){
            updateBeginPosition(currentLoc)
            self.position.x += diff
            print("max pos \(self.maxPosX) and min pos \(self.minPosX)")
        }
        else{
            self.position.x += diff
        }
        
        if(self.position.x > self.maxPosX){
            print("max range reached at \(self.position.x)")
            self.position.x = self.maxPosX
            
        }
        else if(self.position.x < self.minPosX){
            print("min range reached at \(self.position.x)")
            self.position.x = self.minPosX
        }
        print("diff pos is \(diff)")
    }
    
    func updateBeginPosition(_ currentLoc: CGPoint){
        if(self.position == nil){
            //self.maxPosX += currentLoc.x
            //self.minPosX += currentLoc.x
            self.position = CGPoint(x: 0, y: 0)//CGPoint(x: currentLoc.x, y: currentLoc.y)
            print("max pos \(self.maxPosX) and min pos \(self.minPosX)")
        }
        
    }
    
}

/*
 SliderSnap filter class
 Use this to create snap filter for various knob functions (instrument selection, tempo ...etc)
 */


class SliderSnapFilter {
    
    var positions = [CGFloat]() //list of positions for each detent number
    var count: Int! //divide position range by this number to get position per detent
    var offset: CGFloat! //position offset, where angles will start from
    var range: CGFloat! //for ex: 0 - 100
    var pos_per_detent: CGFloat!
    var scale: CGFloat = 5.0
    var scale_offset: CGFloat = 5.0
    
    
    var maxPosition: CGFloat {
        return offset
    }
    
    var minPosition: CGFloat {
        return offset - range
    }
    //MARK: Initialize slider snap filter
    init(detentCount: Int = 10, posOffset: CGFloat = 0, posRange: CGFloat = 100){
        count = detentCount
        offset = posOffset
        range = posRange
        
        //calculate pos per detents using count and range
        //ex: if range = 360 deg and count = 10 then angle per detent = 36 deg
        pos_per_detent = abs(range / CGFloat(count))
        self.initPositions()
    }
    
    //MARK: Initialize pos list
    func initPositions(){
        for i in 0..<count {
            let pos = offset + self.pos_per_detent*CGFloat(i) //ex: 0 + 36*2 = 72
            positions.append(pos)
        }
    }
    
    //MARK: Get detent from angle
    func getDetent(_ pos: CGFloat)->Int{
        let detent = abs(Int((pos-offset)/self.pos_per_detent))
        return detent
        
    }
    
    func getScaledDetent(_ pos: CGFloat)->CGFloat{
            let raw_detent = getDetent(pos)
            return CGFloat(raw_detent)*self.scale + self.scale_offset
    }
    
    //MARK: Get detent position
    func getDetentPos(_ detent: Int)->CGFloat{
        if(detent < positions.count){
            return positions[detent]
            
        }
        else{
            return 0
        }
    }
    
}
