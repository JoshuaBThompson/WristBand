//
//  Left.swift
//  Groover
//
//  Created by Alex Crane on 7/6/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Left: UIButton {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawLeftCanvas()
        print("left displaying!")
    }
    
    func updateState(){
        setNeedsDisplay()
        print("left arrow needs display")
    }
    
}