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
    //MARK: Computed properties
    let max_tempo_bpm: Int = 200
    var tempo: Int {
        if(self.position==nil){
            return 1
        }
        var tempo_bpm = Int(self.position.x * (CGFloat(self.max_tempo_bpm)/(self.maxPosX - self.minPosX)))
        if(tempo_bpm < 1){
            tempo_bpm = 1
        }
        else if(tempo_bpm > self.max_tempo_bpm){
            tempo_bpm = self.max_tempo_bpm
        }
        
        return tempo_bpm
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
