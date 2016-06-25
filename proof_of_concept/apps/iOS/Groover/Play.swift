//
//  Play.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Play: PlayRecordButton {
    
    override func drawRect(rect: CGRect) {
        print("Play!")
        GrooverUI.drawPlayCanvas(playSelected: on)
    }
 
    
}
