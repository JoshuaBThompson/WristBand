//
//  PlayRecordButtons.swift
//  Groover
//
//  Created by Joshua Thompson on 6/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class PlayRecordButton: UIButton {
    
    var on = false
    
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
