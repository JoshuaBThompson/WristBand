//
//  VolumeSliderCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/14/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit


class VolumeSliderCtrl: SliderCtrl{
    
    //Computed Variables
    //MARK: Computed variables
    var volume: Int {
        if(self.position==nil){
            return 1
        }
        
        var volume_prcnt = Int(self.scaled_detent)
        
        if(volume_prcnt < 1){
            volume_prcnt = 1
        }
        else if(volume_prcnt > self.max_value){
            volume_prcnt = self.max_value
        }
        
        return volume_prcnt
    }
    
    func init_vars(){
        self.max_value = 100
        self.min_value = 0
        self.default_value = 75
        self.maxPosX = 190.0
        self.minPosX = 5.0
        self.snapFilter = SliderSnapFilter(detentCount: 100, posOffset: self.minPosX, posRange: self.maxPosX)
        self.snapFilter.scale = 1.0 /* tempo is updated by 5 pbm at a time using the slider */
        self.snapFilter.scale_offset = 0.0
        
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
