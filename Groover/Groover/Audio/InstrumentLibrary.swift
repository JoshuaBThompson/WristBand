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

class SavedInstrument: MidiInstrument{
    /// Create the synth Snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    
    init(soundFilePath: String, position_map: [String: SoundMapInfo]) {
        super.init()
        let url = URL(fileURLWithPath: soundFilePath)
        do {
            let audioFile = try AKAudioFile(forReading: url)
            try sampler.loadAudioFile(audioFile)
            self.name = soundFilePath.fileName()
            self.sound_map = position_map[name]
            if(self.sound_map != nil){
                self.name = self.sound_map.name
            }
            else{
                print("failed to load sound")
            }
            print("url: \(url)")
        }
        catch {
            print("error: \(error)")
        }
        
        self.avAudioNode = sampler.avAudioNode
    }
    
}

class SoundLibrary {
    var instruments = [MidiInstrument]()
    var position_map: [String: SoundMapInfo]!
    var soundLibraryList: [String]!
    var subDirectory: String!
    var sound_lib_helper = SoundLibraryHelper()
    
    init(location: String="Main", subDirectory: String=DefaultSoundsLibrary){
        load(location: location, subDirectory: subDirectory)
    }
    
    func load(location: String="Main", subDirectory: String=DefaultSoundsLibrary){
        self.subDirectory = subDirectory
        if(location == "Main"){
            self.position_map = SoundMapCollection[self.subDirectory]
            getSoundsFromMainBundle()
        }
        else if(location == "Documents"){
            //TODO: add documents sound finder
        }
        else if(location == "Library"){
            //TODO: add library sound finder
        }
    }
    
    func isLib(location: String="Main", subDirectory: String=DefaultSoundsLibrary) -> Bool{
        if(location == "Main"){
            if(SoundMapCollection[subDirectory] != nil){
                return true
            }
        }
        else if(location == "Documents"){
            //TODO: add documents sound finder
        }
        else if(location == "Library"){
            //TODO: add library sound finder
        }
        
        return false
    }
    
    func getSoundsFromMainBundle(){
        instruments.removeAll() //clear
        
        soundLibraryList = sound_lib_helper.getSoundsFromLibraryPath(directory: self.subDirectory)
        for soundPath in soundLibraryList {
            let inst = SavedInstrument(soundFilePath: soundPath, position_map: self.position_map)
            
            instruments.append(inst)
            
            print("!got sound \(inst.name)")
        }
    }
}
