//
//  Triplet.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Triplet: QuantizeButton {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawTripletCanvas()
    }
    
}
