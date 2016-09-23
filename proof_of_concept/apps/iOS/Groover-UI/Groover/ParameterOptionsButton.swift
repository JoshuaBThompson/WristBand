//
//  ParameterOptionsButton.swift
//  Groover
//
//  Created by Joshua Thompson on 8/10/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit


enum ParametersButtonTypes {
    case clear
    case solo
    case mute
    case measure_LEFT
    case measure_RIGHT
}

typealias ParametersButtonTypes_t = ParametersButtonTypes

class ParameterOptionsButton: UIButton {

    var type: ParametersButtonTypes!
    var on: Bool!

}

class ParametersMeasureLeft: ParameterOptionsButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawLeftCanvas()
        print("left displaying!")
    }
    
    func updateState(){
        setNeedsDisplay()
        print("left arrow needs display")
    }
    
}

class ParametersMeasureRight: ParameterOptionsButton {
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawRightCanvas()
        print("right displaying!")
    }
    
    func updateState(){
        setNeedsDisplay()
        print("right arrow needs display")
    }
    
}
