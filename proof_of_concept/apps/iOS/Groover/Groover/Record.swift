//
//  Record.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Record: UIButton {
    var on = false
    
    //MARK: initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        GrooverUI.drawRecordCanvas(recordSelected: on)
    }
    
    //MARK: touch functions
    func toggleState(){
        on = !on
        setNeedsDisplay()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("record touch began")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("record touch ended")
        toggleState()
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed

    }
    
    
}
