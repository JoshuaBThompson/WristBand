//
//  RectBtn.swift
//  Groover
//
//  Created by Alex Crane on 7/19/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class RectBtn: UIView {
    
    override func drawRect(rect: CGRect) {
        UIGroover.drawQuarterCanvas()
    }
    
}