//
//  SettingsIconCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/30/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

@IBDesignable
class SettingsIconCtrl: SettingsIcon {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawSettingsIconCanvas()
    }
    
    func hide(){
        isHidden = true
    }
    
    func show(){
        isHidden = false
    }
    
}
