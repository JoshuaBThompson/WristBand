//
//  PositionIndicator.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class PositionIndicator: UIView {
    var currentPos: Int = 0
    let minPos = 0
    let maxPos = 17
    
    override func drawRect(rect: CGRect) {
        updatePosistion()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hidden = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hidden = true
        
    }
    
    func toggleHide(){
        hidden = !hidden
    }
    
    func hide(){
        hidden = true
    }
    
    func show(){
        hidden = false
    }
    
    func setPosition(newPos: Int){
        if(newPos >= minPos && newPos <= maxPos){
            currentPos = newPos
        }
        setNeedsDisplay() //tells swift to update drawing
    }
    
    func updatePosistion(){
        switch currentPos {
        case 0:
            UIGroover.drawPositionsCanvas(position1Selected: true)
            break
        case 1:
            UIGroover.drawPositionsCanvas(position2Selected: true)
            break
        case 2:
            UIGroover.drawPositionsCanvas(position3Selected: true)
            break
        case 3:
            UIGroover.drawPositionsCanvas(position4Selected: true)
            break
        case 4:
            UIGroover.drawPositionsCanvas(position5Selected: true)
            break
        case 5:
            UIGroover.drawPositionsCanvas(position6Selected: true)
            break
        case 6:
            UIGroover.drawPositionsCanvas(position7Selected: true)
            break
        case 7:
            UIGroover.drawPositionsCanvas(position8Selected: true)
            break
        case 8:
            UIGroover.drawPositionsCanvas(position9Selected: true)
            break
        case 9:
            UIGroover.drawPositionsCanvas(position10Selected: true)
            break
        case 10:
            UIGroover.drawPositionsCanvas(position11Selected: true)
            break
        case 11:
            UIGroover.drawPositionsCanvas(position12Selected: true)
            break
        case 12:
            UIGroover.drawPositionsCanvas(position13Selected: true)
            break
        case 13:
            UIGroover.drawPositionsCanvas(position14Selected: true)
            break
        case 14:
            UIGroover.drawPositionsCanvas(position15Selected: true)
            break
        case 15:
            UIGroover.drawPositionsCanvas(position16Selected: true)
            break
        case 16:
            UIGroover.drawPositionsCanvas(position17Selected: true)
            break
        case 17:
            UIGroover.drawPositionsCanvas(position18Selected: true)
            break
        default:
            break
            
        }
    }
    
    
}
