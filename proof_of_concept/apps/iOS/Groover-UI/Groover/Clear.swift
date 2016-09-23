//
//  Clear.swift
//  Groover
//
//  Created by Joshua Thompson on 7/12/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class Clear: PlayRecordButton {
    
    override func draw(_ rect: CGRect) {
        print("clear!")
        let clearOn = (on && set) //must make set = true after user hits record
        //only allow clear after record has been turned on
        if(set){
            UIGroover.drawClearCanvas(clearSelected: clearOn)
        }
    }
}
