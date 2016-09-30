//
//  Right.swift
//  Groover
//
//  Created by Alex Crane on 7/13/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class Right: PopupButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawRightCanvas()
        print("right displaying!")
    }

    
}
