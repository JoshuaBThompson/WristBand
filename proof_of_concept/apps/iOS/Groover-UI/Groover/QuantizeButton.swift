//
//  QuantizeButton.swift
//  Groover
//
//  Created by Joshua Thompson on 8/23/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit


enum QuantizeButtonTypes: Int {
    case quarter = 0
    case eight = 1
    case sixteenth = 2
    case thirtysec = 3
    case triplet = 4
}

typealias QuantizeButtonTypes_t = QuantizeButtonTypes

class QuantizeButton: UIButton {
    var resolution = 1.0
    var on = false
    var set = false //used for clear button only, for now...
    var type: QuantizeButtonTypes!
    var active: Bool {
        return on && set && isSelected
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    //MARK: touch functions
    func toggleState(){
        on = !on
        updateState()
    }
    
    func updateState(){
        setNeedsDisplay()
    }

}
