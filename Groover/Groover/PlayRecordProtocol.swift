//
//  PlayRecordProtocol.swift
//  Groover
//
//  Created by Joshua Thompson on 9/24/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation

enum PlayRecordButtonTypes: Int {
    case PLAY = 0
    case RECORD = 1
}

typealias PlayRecordButtonTypes_t = PlayRecordButtonTypes


protocol PlayRecordProtocol {
    var type: PlayRecordButtonTypes_t {get set}
}
