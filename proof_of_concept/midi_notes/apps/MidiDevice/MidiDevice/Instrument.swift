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
    var pluckNode: AKOperationGenerator!
    
    
    init(){
        midi.openMIDIIn("Session 1")
        midi.addListener(self)
        let playRate = 2.0
        
        let frequency = (AKOperation.parameters(0) + 40).midiNoteToFrequency()
        let pluck = AKOperation.pluckedString(trigger: AKOperation.trigger, frequency: frequency, amplitude: 0.5, lowestFrequency: 50)
        pluckNode = AKOperationGenerator(operation: pluck)
        
        let delay  = AKDelay(pluckNode)
        delay.time = 1.5 / playRate
        delay.dryWetMix = 0.3
        delay.feedback = 0.2
        
        let reverb = AKReverb(delay)
        
        AudioKit.output = reverb
        AudioKit.start()
        pluckNode.start()
        status = "initialized"
        print("instrument initialized")
        
    }
    
    func midiNoteOn(note: Int, velocity: Int, channel: Int) {
        //make sound
        
    }
    
    func playString(){
        var note = 20
        print("playString")
        let octave = randomInt(0...3)  * 12
        if random(0, 10) < 1.0 { note = note+1; }
        
        if random(0, 6) > 1.0 {
            pluckNode.trigger([Double(note + octave)])
        }
    }
}

