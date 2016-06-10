//
//  Play.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Play: UIButton {
    var on = false
    override func drawRect(rect: CGRect) {
        GrooverUI.drawPlayCanvas(playSelected: on)
    }
    
    //MARK: touch functions
    func toggleState(){
        on = !on
        setNeedsDisplay()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("play touch began")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("play touch ended")
        toggleState()
    }
    
}
