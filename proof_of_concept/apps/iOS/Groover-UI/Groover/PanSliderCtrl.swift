//
//  PanSliderCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/14/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class PanSliderCtrl: SliderCtrl{
    //MARK: Properties
    let pan_scale: Double = 0.01
    let min_pan: Double = -1.0
    let max_pan: Double = 1.0
    
    let pan_prcnt_to_dec_scale = 0.01
    
    //MARK: Computed variables
    var pan: Double {
        if(self.position==nil){
            return 1
        }
        
        var pan_abs_prcnt = Int(self.scaled_detent)
        
        if(pan_abs_prcnt < self.min_value){
            pan_abs_prcnt = self.min_value
        }
        else if(pan_abs_prcnt > self.max_value){
            pan_abs_prcnt = self.max_value
        }
        
        return Double(pan_abs_prcnt)*self.pan_prcnt_to_dec_scale // change to decimal (ex: +100% = +1.0)
    }
    
    func init_vars(){
        self.max_value = 100
        self.min_value = -100
        self.default_value = 0
        self.maxPosX = 190.0
        self.minPosX = 5.0
        self.snapFilter = SliderSnapFilter(detentCount: 200, posOffset: self.minPosX, posRange: self.maxPosX)
        self.snapFilter.scale = 1.0 /* tempo is updated by 5 pbm at a time using the slider */
        self.snapFilter.scale_offset = -100.0
        
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
            self.update_pos_from_value(new_value: self.default_value)
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            
        }
        else{
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
        }
    }
        
}
