//
//  Left.swift
//  Groover
//
//  Created by Alex Crane on 7/6/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class Left: PopupButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawLeftCanvas()
        print("left displaying!")
        
    }
    
}
