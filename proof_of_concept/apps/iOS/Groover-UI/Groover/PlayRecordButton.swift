//
//  PlayRecordButton.swift
//  Groover
//
//  Created by Joshua Thompson on 7/12/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation

import UIKit

enum PlayRecordButtonTypes: Int {
    case PLAY = 0
    case CLEAR = 1
    case RECORD = 2
}

typealias PlayRecordButtonTypes_t = PlayRecordButtonTypes

class PlayRecordButton: UIButton {
    
    var on = false
    var set = false //used for clear button only, for now...
    var type: PlayRecordButtonTypes!
    var active: Bool {
        return on && set && selected
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    //MARK: touch functions
    func toggleState(){
        on = !on
        updateState()
    }
    
    func updateState(){
        setNeedsDisplay()
    }
    
    
    
}
