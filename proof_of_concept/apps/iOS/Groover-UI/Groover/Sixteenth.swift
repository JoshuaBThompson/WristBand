//
//  Sixteenth.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Sixteenth: QuantizeButton {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawSixteenthCanvas(sixteenthSelected: selected, sixteenthActive: on)
    }
    
}
