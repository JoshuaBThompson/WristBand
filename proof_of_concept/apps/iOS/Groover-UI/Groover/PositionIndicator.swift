//
//  PositionIndicator.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class PositionIndicator: UIView {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawPositionsCanvas()
    }
    
}
