//
//  PopupButton.swift
//  Groover
//
//  Created by Joshua Thompson on 7/31/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

enum PopupButtonTypes: Int {
    case UPPER_LEFT = 0
    case UPPER_RIGHT = 1
    case LOWER_LEFT = 2
    case LOWER_RIGHT = 3
}
typealias PopupButtonTypes_t = PopupButtonTypes

class PopupButton: UIButton {
    var type: PopupButtonTypes!
    

}
