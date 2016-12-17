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
    
    //MARK: Properties
    let max_tempo_bpm: Int = 200
    let min_tempo_bpm: Int = 1
    let default_tempo_bpm: Int = 60
    
    //MARK: Computed properties
    var pos_to_tempo_scale: CGFloat {
        return CGFloat(self.max_tempo_bpm - self.min_tempo_bpm)/(self.maxPosX - self.minPosX)
    }
    
    var tempo_offset: CGFloat {
        /*
         y = mx + b -> t = m*p + offset
         offset = t - m*p when t = 1 p = 5
         offset = t - m*5
         m = max_temp - min_temp / maxPos - minPos
         */
        let offset = CGFloat(self.min_tempo_bpm) - (self.pos_to_tempo_scale*self.minPosX)
        return offset
    }
    
    var pos_offset: CGFloat {
        /*
         y = mx + b -> p = m*t + offset
         offset = p - m*t when p = 5 t = 1
         offset = p - m*1
         m = max_pos - min_pos / max_tempo - min_tempo
        */
        let offset = self.minPosX - (CGFloat(self.min_tempo_bpm)/(self.pos_to_tempo_scale))
        return offset
    }
    
    var tempo: Int {
        if(self.position==nil){
            return 1
        }
        
        var tempo_bpm = Int(self.scaled_detent)

        if(tempo_bpm < 1){
            tempo_bpm = 1
        }
        else if(tempo_bpm > self.max_tempo_bpm){
            tempo_bpm = self.max_tempo_bpm
        }
        
        
        return tempo_bpm
    }
    
    func init_vars(){
        self.maxPosX = 190.0
        self.minPosX = 5.0
        self.snapFilter = SliderSnapFilter(detentCount: 40, posOffset: self.minPosX, posRange: self.maxPosX)
        self.snapFilter.scale = 5.0 /* tempo is updated by 5 pbm at a time using the slider */
        
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
            self.update_pos_from_tempo(new_tempo: self.default_tempo_bpm)
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            
        }
        else{
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            print("detent is \(self.detent)")
            print("scaled detent is \(self.scaled_detent)")
        }
    }
    
    //MARK: Update position x from tempo
    func update_pos_from_tempo(new_tempo: Int){
        
        var new_pos = CGFloat(new_tempo) * (self.maxPosX - self.minPosX) / CGFloat(self.max_tempo_bpm - self.min_tempo_bpm)
        new_pos = new_pos + self.pos_offset
        self.position.x = new_pos
        print("Init temp is \(self.tempo)")
    }
}
