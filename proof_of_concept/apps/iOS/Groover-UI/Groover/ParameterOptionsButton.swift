//
//  ParameterOptionsButton.swift
//  Groover
//
//  Created by Joshua Thompson on 8/10/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit


enum ParametersButtonTypes: Int {
    case CLEAR = 0
}

typealias ParametersButtonTypes_t = ParametersButtonTypes

class ParameterOptionsButton: UIButton {

    var type: ParametersButtonTypes!

}
