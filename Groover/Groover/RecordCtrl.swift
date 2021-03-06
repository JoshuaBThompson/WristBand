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
    var preroll: Bool = false
    var recording: Bool = false
    var stopped: Bool = false

    override func draw(_ rect: CGRect) {
        UIGroover.drawRecordCanvas(recordFrame: self.bounds, recordSelected: recording, recordTransitioning: preroll)
        
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
    
    func setRecording(){
        preroll = false
        recording = true
        stopped = false
        setNeedsDisplay()
    }
    
    func setPreroll(){
        preroll = true
        recording = false
        stopped = false
        setNeedsDisplay()
    }
    
    func setStopped(){
        preroll = false
        recording = false
        stopped = true
        setNeedsDisplay()
    }
    
}
