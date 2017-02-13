//
//  InstrumentLibrary.swift
//  Groover
//
//  Created by Joshua Thompson on 2/13/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation
import AudioKit

/****************Snare Instrument 1
 Desc: This synth drum replicates a Snare instrument
 *****************/

class SavedInstrument: SynthInstrument{
    /// Create the synth Snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(soundFilePath: String) {
        super.init()
        let url = URL(fileURLWithPath: soundFilePath)
        do {
            let audioFile = try AKAudioFile(forReading: url)
            try sampler.loadAudioFile(audioFile)
            name = soundFilePath.fileName()
            print("url: \(url)")
        }
        catch {
            print("error: \(error)")
        }
        
        self.avAudioNode = sampler.avAudioNode
    }
    
}

class SoundLibrary {
    var instruments = [SynthInstrument]()
    var soundLibraryList: [String]!
    var subDirectory: String!
    
    init(location: String="Main", subDirectory: String="Sounds_Extra"){
        
        if(location == "Main"){
            getSoundsFromMainBundle()
        }
        else if(location == "Documents"){
            //TODO: add documents sound finder
        }
        else if(location == "Library"){
            //TODO: add library sound finder
        }
        
    }
    
    func getSoundsFromMainBundle(){
        soundLibraryList = SoundLibraryHelper.getSoundsFromLibraryPath(directory: self.subDirectory)
        for soundPath in soundLibraryList {
            instruments.append(SavedInstrument(soundFilePath: soundPath))
        }
    }
}
