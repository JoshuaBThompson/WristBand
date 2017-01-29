//
//  Measures.swift
//  Groover
//
//  Created by Alex Crane on 10/29/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit
 
 @IBDesignable
 class Measure: UIView {
    var measure_progress: CGFloat = 17.0
     override func draw(_ rect: CGRect) {
        UIGroover.drawMeasureCanvas(measureFrame: self.bounds, measureProgress: measure_progress)
     }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func updateMeasureProgress(progress_prcnt: CGFloat){
        measure_progress += progress_prcnt
        print("measure progress updated to \(measure_progress)")
    }
 
 }
