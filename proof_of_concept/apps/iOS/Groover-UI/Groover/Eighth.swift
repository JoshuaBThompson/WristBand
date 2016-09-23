//
//  Eighth.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Eighth: QuantizeButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawEighthCanvas(eighthSelected: isSelected, eighthActive: on)
    }
    
}
