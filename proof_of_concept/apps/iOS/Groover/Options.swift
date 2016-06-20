//
//  Options.swift
//  Groover
//
//  Created by Joshua Thompson on 6/10/16.
//  Copyright © 2016 TCM. All rights reserved.
//

/*
 * This is the parent class for all other option buttons
 * They inherit from this class so that we can make global changes easier in this class that will transmit to the children
 */

import UIKit

class Options: UIButton {
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
    /*
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("option touch began")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("option touch ended")
        toggleState()
    }
     */


}
