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
    var hideDraw = false
    var positions_selected = [Bool]()
    var positions_visible = [Bool]()
    
    override func draw(_ rect: CGRect) {
        if(!hideDraw){
            updatePosition()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_positions_list()
        hide()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_positions_list()
        hide()
        
    }
    
    func init_positions_list(){
        for _ in minPos ... maxPos {
            self.positions_selected.append(false)
            self.positions_visible.append(true)
        }
        self.positions_selected[0] = true
    }
    
    func set_max_position(max_pos: Int){
        if(max_pos <= maxPos){
            for i in max_pos ... maxPos {
                self.positions_visible[i] = false
            }
        }
        setNeedsDisplay()
    }
    
    func toggleHide(){
        //isHidden = !isHidden
        hideDraw = !hideDraw
    }
    
    func hide(){
        hideDraw = true
        setNeedsDisplay()
    }
    
    func show(){
        hideDraw = false
        setNeedsDisplay()
    }
    
    func setPosition(_ newPos: Int){
        if(newPos >= minPos && newPos <= maxPos){
            self.positions_selected[currentPos] = false
            currentPos = newPos
            self.positions_selected[currentPos] = true
            
        }
        setNeedsDisplay() //tells swift to update drawing
    }
    
    func updatePosition(){
        if(hideDraw){
            return
        }
        update_all()
        /*
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
 */
    }
    
    func update_all(){
        UIGroover.drawPositionsCanvas(position1Selected: positions_selected[0],
                                      position2Selected: positions_selected[1],
                                      position3Selected: positions_selected[2],
                                      position4Selected: positions_selected[3],
                                      position5Selected: positions_selected[4],
                                      position6Selected: positions_selected[5],
                                      position7Selected: positions_selected[6],
                                      position8Selected: positions_selected[7],
                                      position9Selected: positions_selected[8],
                                      position10Selected: positions_selected[9],
                                      position11Selected: positions_selected[10],
                                      position12Selected: positions_selected[11],
                                      position13Selected: positions_selected[12],
                                      position14Selected: positions_selected[13],
                                      position15Selected: positions_selected[14],
                                      position16Selected: positions_selected[15],
                                      position17Selected: positions_selected[16],
                                      position18Selected: positions_selected[17],
                                      position1Visible: positions_visible[0],
                                      position2Visible: positions_visible[1],
                                      position3Visible: positions_visible[2],
                                      position4Visible: positions_visible[3],
                                      position5Visible: positions_visible[4],
                                      position6Visible: positions_visible[5],
                                      position7Visible: positions_visible[6],
                                      position8Visible: positions_visible[7],
                                      position9Visible: positions_visible[8],
                                      position10Visible: positions_visible[9],
                                      position11Visible: positions_visible[10],
                                      position12Visible: positions_visible[11],
                                      position13Visible: positions_visible[12],
                                      position14Visible: positions_visible[13],
                                      position15Visible: positions_visible[14],
                                      position16Visible: positions_visible[15],
                                      position17Visible: positions_visible[16],
                                      position18Visible: positions_visible[17])
    }
    
}
