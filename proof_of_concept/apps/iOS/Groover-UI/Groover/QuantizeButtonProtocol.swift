//
//  QuantizeButtonProtocol.swift
//  Groover
//
//  Created by Joshua Thompson on 9/24/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

let QuarterResolution = 1.0
let EighthResolution = 2.0
let SixteenthResolution = 4.0
let ThirtysecondResolution = 16.0
let TripletResolution = 3.0

@objc protocol QuantizeButtonProtocol: class {
    var resolution: Double {get set}
    var on: Bool {get set}
}
