//
//  Quantize.swift
//  Groover
//
//  Created by Alex Crane on 10/29/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class QuantizeButtons: UIButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawQuantizationCanvas()
    }
    
}
