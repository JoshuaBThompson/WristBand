//
//  ParameterOptionsButton.swift
//  Groover
//
//  Created by Joshua Thompson on 8/10/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit


enum ParametersButtonTypes {
    case CLEAR
    case SOLO
    case MUTE
}

typealias ParametersButtonTypes_t = ParametersButtonTypes

class ParameterOptionsButton: UIButton {

    var type: ParametersButtonTypes!
    var on: Bool!

}
