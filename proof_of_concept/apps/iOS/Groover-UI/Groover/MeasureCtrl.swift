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
    var max_progress: CGFloat = 76.5
    var start_width: CGFloat = 0.0
    var progress_view: UIView!
    var max_progress_set = false
    var active = false

    
    override func draw(_ rect: CGRect) {
        if(!max_progress_set){
            max_progress = self.bounds.size.width
            print("max_progress = \(max_progress)")
        }
        
        UIGroover.drawMeasureCanvas(measureFrame: self.bounds, measureActive: active, measureProgress: measure_progress)
            //// measureActiveFill Drawing
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    //Clear the progress bar
    func clearProgress(){
        measure_progress = 0.0
        setNeedsDisplay()
    }
    
    //Update progress variable and width
    func updateMeasureProgress(progress_prcnt: CGFloat){
        measure_progress = (progress_prcnt * max_progress)
        if(measure_progress > max_progress){
            measure_progress = max_progress
        }
        setNeedsDisplay()
    }
}
