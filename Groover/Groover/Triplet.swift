//
//  Triplet.swift
//  Groover
//
//  Created by Alex Crane on 7/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class Triplet: UIButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawTripletCanvas(tripletFrame: self.bounds)
    }
    
}
