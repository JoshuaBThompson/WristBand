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
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawSixteenthCanvas(sixteenthSelected: isSelected, sixteenthActive: on)
    }
    
}
