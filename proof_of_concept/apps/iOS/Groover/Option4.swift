//
//  Option4.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Option4: Options {
    
    override func drawRect(rect: CGRect) {
        GrooverUI.drawOptionsCanvas4(optionFourSelected: on)
    }
    
}