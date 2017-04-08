//
//  Thirtysecond.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class Thirtysecond: UIButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawThirtysecondCanvas(thirtySecondFrame: self.bounds)
    }
    
}
