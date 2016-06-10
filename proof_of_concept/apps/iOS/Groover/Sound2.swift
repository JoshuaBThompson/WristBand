//
//  Sound2.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

//@IBDesignable
class Sound2: Sounds {
    
    override func drawRect(rect: CGRect) {
        GrooverUI.drawSoundCanvasTwo(soundTwoSelected: on)
    }
    
}
