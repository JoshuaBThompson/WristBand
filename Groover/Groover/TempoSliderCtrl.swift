//
//  TempoSliderCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class TempoSliderCtrl: SliderCtrl{
    
    //MARK: Computed variables
    var tempo: Int {
        if(self.position==nil){
            return 1
        }
        
        var tempo_bpm = Int(self.scaled_detent)

        if(tempo_bpm < 1){
            tempo_bpm = 1
        }
        else if(tempo_bpm > self.max_value){
            tempo_bpm = self.max_value
        }
        
        
        return tempo_bpm
    }
    
    func init_vars(){
        self.max_value = 200
        self.min_value = 1
        self.default_value = 60
        self.maxPosX = 190.0
        self.minPosX = 5.0
        self.snapFilter = SliderSnapFilter(detentCount: 200, posOffset: self.minPosX, posRange: self.maxPosX)
        self.snapFilter.scale = 1.0 /* tempo is updated by 1 pbm at a time using the slider */
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
    
    override func update_pos_from_detent(new_detent: Int) {
        super.update_pos_from_detent(new_detent: new_detent)
        print("tempo detent updated from \(new_detent)")
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
