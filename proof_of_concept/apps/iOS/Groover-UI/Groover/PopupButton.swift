//
//  PopupButton.swift
//  Groover
//
//  Created by Joshua Thompson on 7/31/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

enum PopupButtonTypes: Int {
    case upper_LEFT = 0
    case upper_RIGHT = 1
    case lower_LEFT = 2
    case lower_RIGHT = 3
}
typealias PopupButtonTypes_t = PopupButtonTypes

class PopupButton: UIButton {
    var type: PopupButtonTypes!
    

}
