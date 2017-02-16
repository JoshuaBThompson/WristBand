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
    var position_map: [String: Int]!
    var soundLibraryList: [String]!
    var subDirectory: String!
    var sound_lib_helper = SoundLibraryHelper()
    
    init(location: String="Main", subDirectory: String="Sounds_Extra"){
        self.subDirectory = subDirectory
        if(location == "Main"){
            getSoundsFromMainBundle()
            self.position_map = SoundMapCollection[self.subDirectory]
        }
        else if(location == "Documents"){
            //TODO: add documents sound finder
        }
        else if(location == "Library"){
            //TODO: add library sound finder
        }
    }
    
    func getSoundsFromMainBundle(){
        soundLibraryList = sound_lib_helper.getSoundsFromLibraryPath(directory: self.subDirectory)
        for soundPath in soundLibraryList {
            let inst = SavedInstrument(soundFilePath: soundPath)
            instruments.append(inst)
            print("!got sound \(inst.name)")
        }
    }
}
