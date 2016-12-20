//
//  SongTemplate.swift
//  Groover
//
//  Created by Joshua Thompson on 12/20/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class SongTemplate {
    // MARK: Properties
    var name: String
    var num: Int!
    
    //Mark: Init
    init?(name: String, num: Int) {
        self.name = name
        self.num = num
        
        if name.isEmpty {
            return nil
        }
    }
}
