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
    var previousLocation: CGPoint!
    var previousTimestamp = 0.0
    var minPosUpdateTime = 0.025 //25ms
    var maxPosX: CGFloat = 95
    var minPosX: CGFloat = -95.0
    var position: CGPoint!
    
    
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
