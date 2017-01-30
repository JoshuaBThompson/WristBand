//
//  MeasureCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 1/29/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import UIKit

class MeasureCtrl: Measure {
    //MARK: properties
    var measure_progress: CGFloat = 0.0
    var max_progress: CGFloat = 74.0
    var start_width: CGFloat = 0.0
    var progress_view: UIView!

    
    override func draw(_ rect: CGRect) {
        UIGroover.drawMeasureCanvas(measureFrame: self.bounds, measureProgress: measure_progress)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    //Update progress variable and width
    func updateMeasureProgress(progress_prcnt: CGFloat){
        measure_progress += progress_prcnt//(progress_prcnt * max_progress)
        if(measure_progress >= max_progress){
            measure_progress = 0.0
        }
        //self.updateProgressViewWidth(width: self.measure_progress)
        setNeedsDisplay()
    }
}
