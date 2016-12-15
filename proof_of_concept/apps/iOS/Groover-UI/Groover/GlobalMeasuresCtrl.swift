//
//  GlobalMeasuresCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class GlobalMeasuresCtrl: SliderCtrl{
    //MARK: Computed properties
    let max_measures: Int = 15
    var measures: Int {
        if(self.position==nil){
            return 1
        }
        var measure_count = Int(self.position.x * (CGFloat(self.max_measures)/(self.maxPosX - self.minPosX)))
        if(measure_count < 1){
            measure_count = 1
        }
        else if(measure_count > max_measures){
            measure_count = max_measures
        }
        
        return measure_count
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.maxPosX = 190.0
        self.minPosX = 5.0
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.maxPosX = 190.0
        self.minPosX = 5.0
    }
    
    
    //MARK: Draw
    override func draw(_ rect: CGRect) {
        if(self.position == nil){
            UIGroover.drawSliderCanvas()
        }
        else{
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
        }
    }
}
