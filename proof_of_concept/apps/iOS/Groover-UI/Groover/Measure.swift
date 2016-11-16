//
//  Measures.swift
//  Groover
//
//  Created by Alex Crane on 10/29/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit
 
 @IBDesignable
 class Measure: UIButton {
 
     override func draw(_ rect: CGRect) {
         UIGroover.drawMeasureCanvas(measureFrame: self.bounds)
     }
 
 }
