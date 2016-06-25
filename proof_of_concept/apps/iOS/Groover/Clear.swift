//
//  Clear.swift
//  Groover
//
//  Created by Joshua Thompson on 6/23/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class Clear: PlayRecordButton {
    
    override func drawRect(rect: CGRect) {
        print("clear!")
        let clearOn = (on && set) //must make set = true after user hits record
                                  //only allow clear after record has been turned on
        if(set){
            GrooverUI.drawClearCanvas(clearSelected: clearOn)
        }
    }
}