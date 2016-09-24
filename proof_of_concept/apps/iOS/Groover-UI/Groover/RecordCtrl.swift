//
//  RecordCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/24/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class RecordCtrl: Record, PlayRecordProtocol {
    //MARK: properties
    var type: PlayRecordButtonTypes_t = .RECORD
    
    override func draw(_ rect: CGRect) {
        UIGroover.drawRecordCanvas(recordSelected: isSelected)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
        
    }
    
    func buttonTapped(){
        print("record button tapped")
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }

}
