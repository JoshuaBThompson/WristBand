//
//  Right.swift
//  Groover
//
//  Created by Alex Crane on 7/13/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Right: UIButton {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawRightCanvas()
        print("right displaying!")
    }
    
    func updateState(){
        setNeedsDisplay()
        print("right arrow needs display")
    }
    
}
