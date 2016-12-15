//
//  TimeSigSliderCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class TimeSigSliderCtrl: SliderCtrl{
    
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
