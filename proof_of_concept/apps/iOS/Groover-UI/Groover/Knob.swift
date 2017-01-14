//
//  Knob.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Knob: UIControl {
    override func draw(_ rect: CGRect) {
        let modelNameShort = UIDevice.current.modelName
        if(modelNameShort == "iPhone SE"){
            UIGroover.drawKnobCanvasSE(knobFrame: self.bounds)
        }
        else if(modelNameShort == "iPhone 6and7 Plus"){
            UIGroover.drawKnobCanvas6and7(knobFrame: self.bounds)
        }
        else if(modelNameShort == "iPhone 6and7"){
            UIGroover.drawKnobCanvas6and7plus(knobFrame: self.bounds)
        }
        else{
            UIGroover.drawKnobCanvasSE(knobFrame: self.bounds)
        }
    }
}

