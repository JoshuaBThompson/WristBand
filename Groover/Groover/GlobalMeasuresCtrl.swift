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
    let max_measures: Int = 32
    var measures: Int {
        if(self.position==nil){
            return 1
        }
        var measure_count = Int(self.scaled_detent)
        if(measure_count < 1){
            measure_count = 1
        }
        else if(measure_count > max_measures){
            measure_count = max_measures
        }
        
        return measure_count
    }
    
    func init_vars(){
        self.max_value = self.max_measures
        self.min_value = 1
        self.default_value = 1
        self.maxPosX = 190.0
        self.minPosX = 5.0
        self.snapFilter = SliderSnapFilter(detentCount: self.max_measures, posOffset: self.minPosX, posRange: self.maxPosX)
        self.snapFilter.scale = 1.0 /* tempo is updated by 5 pbm at a time using the slider */
        self.snapFilter.scale_offset = 1.0
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_vars()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_vars()
    }
    
    
    //MARK: Draw
    override func draw(_ rect: CGRect) {
        if(self.position == nil){
            self.position = CGPoint(x: 0, y: 0)
            self.update_pos_from_value(new_value: CGFloat(self.default_value))
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            
        }
        else{
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            print("detent is \(self.detent)")
            print("scaled detent is \(self.scaled_detent)")
        }
    }
}
