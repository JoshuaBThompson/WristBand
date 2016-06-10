//
//  Sound3.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Sound3: Sounds {
    
    override func drawRect(rect: CGRect) {
        GrooverUI.drawSoundCanvasThree(soundThreeSelected: on)
    }
    
}
