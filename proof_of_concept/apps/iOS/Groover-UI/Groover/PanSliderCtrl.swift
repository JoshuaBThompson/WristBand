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
    
    //MARK: Draw
    override func draw(_ rect: CGRect) {
        if(self.position == nil){
            UIGroover.drawPanSliderCanvas()
        }
        else{
            UIGroover.drawPanSliderCanvas(panSliderPosition: self.position.x)
        }
    }
        
}
