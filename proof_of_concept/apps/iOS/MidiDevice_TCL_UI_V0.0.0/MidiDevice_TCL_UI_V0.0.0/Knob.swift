//
//  knob.swift
//  Drum Beats
//
//  Created by Alex Crane on 5/25/16.
//  Copyright © 2016 Alex Crane. All rights reserved.
//

import UIKit

//@IBDesignable
class Knob: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        KnobStyleKit.drawKnob()
    }
 
}
