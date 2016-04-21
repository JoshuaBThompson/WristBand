//
//  Instrument.swift
//  MidiDevice
//
//  Created by sofiebio on 2/13/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import UIKit
import AudioKit

class Instrument: AKMIDIListener {
    var midi = AKMIDI()
    var status = "not started"    
    
    init(){
        midi.openMIDIIn("Session 1")
        midi.addListener(self)
        
    }
    
    func midiNoteOn(note: Int, velocity: Int, channel: Int) {
        //make sound
        
    }
    
}

