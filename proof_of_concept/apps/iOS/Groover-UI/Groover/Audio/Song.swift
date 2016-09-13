//
//  TrackManager.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 4/21/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import CoreFoundation
import AudioKit

class Song {
    var quantizeResolution = 1.0
    var quantizeEnabled = false
    var noteAdded = false
    var selectedInstrument = 0
    var prevSelectedInstrument = 0
    var mixer: AKMixer!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var instruments = [InstrumentTrack]()
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    
    //MARK: computed variables
    
    var presetMeasureCount: Int {
        return instruments[selectedInstrument].trackManager.measureCount
    }
    var selectedInstrumentName: String {
        return instruments[selectedInstrument].instrument.name
    }
    
    var instrument: InstrumentTrack {
        return instruments[selectedInstrument]
    }
    
    init(){
        mixer = AKMixer()
        clickTrack = ClickTrack(songRef: self, clickTempo: tempo, clickTimeSignature: timeSignature)
        mixer.connect(clickTrack)
        
        
        //snare instruments

        let instrument1Track = InstrumentTrack(clickTrack: clickTrack, presetInst: SnareInstrument1())
        instruments.append(instrument1Track)
        mixer.connect(instrument1Track.instrument.panner)
        
        let instrument2Track = InstrumentTrack(clickTrack: clickTrack, presetInst: SnareInstrument2())
        instruments.append(instrument2Track)
        mixer.connect(instrument2Track.instrument.panner)
        
        let instrument3Track = InstrumentTrack(clickTrack: clickTrack, presetInst: SnareInstrument3())
        instruments.append(instrument3Track)
        mixer.connect(instrument3Track.instrument.panner)
        
        let instrument4Track = InstrumentTrack(clickTrack: clickTrack, presetInst: SnareInstrument4())
        instruments.append(instrument4Track)
        mixer.connect(instrument4Track.instrument.panner)
        
        //kick instruments
        
        let instrument5Track = InstrumentTrack(clickTrack: clickTrack, presetInst: KickInstrument1())
        instruments.append(instrument5Track)
        mixer.connect(instrument5Track.instrument.panner)
        
        let instrument6Track = InstrumentTrack(clickTrack: clickTrack, presetInst: KickInstrument2())
        instruments.append(instrument6Track)
        mixer.connect(instrument6Track.instrument.panner)
        
        let instrument7Track = InstrumentTrack(clickTrack: clickTrack, presetInst: KickInstrument3())
        instruments.append(instrument7Track)
        mixer.connect(instrument7Track.instrument.panner)
        
        let instrument8Track = InstrumentTrack(clickTrack: clickTrack, presetInst: KickInstrument4())
        instruments.append(instrument8Track)
        mixer.connect(instrument8Track.instrument.panner)
        
        //hat instruments
        
        let instrument9Track = InstrumentTrack(clickTrack: clickTrack, presetInst: HatInstrument1())
        instruments.append(instrument9Track)
        mixer.connect(instrument9Track.instrument.panner)
        
        let instrument10Track = InstrumentTrack(clickTrack: clickTrack, presetInst: HatInstrument2())
        instruments.append(instrument10Track)
        mixer.connect(instrument10Track.instrument.panner)
        
        let instrument11Track = InstrumentTrack(clickTrack: clickTrack, presetInst: HatInstrument3())
        instruments.append(instrument11Track)
        mixer.connect(instrument11Track.instrument.panner)
        
        let instrument12Track = InstrumentTrack(clickTrack: clickTrack, presetInst: HatInstrument4())
        instruments.append(instrument12Track)
        mixer.connect(instrument12Track.instrument.panner)
        
        //connect all instrument outputs to Audiokit output
        AudioKit.output = mixer
    }
    
    func start(){
        //start audiokit output
        AudioKit.start()
    }
    func clearPreset(){
        //stop()
        instruments[selectedInstrument].trackManager.clear()
    }
    
    func clear(){
        print("calling collections clear!")
        //stop any currently playing tracks first
        stop()
        //clear all recorded tracks
        for instTracks in instruments {
            //clear all recorded tracks
            instTracks.trackManager.clear()
        }        
        
    }
    
    func enableClickTrack(){
        clickTrack.unmute()
        clickTrack.enable()
        
    }
    
    func disableClickTrack(){
        clickTrack.disable()
    }
    
    
    func toggleClickTrackMute(){
        if(clickTrack.muted){
            clickTrack.unmute()
        }
        else{
            clickTrack.mute()
        }
        
    }

    
    func playNote(){
        //play note based on selected instrument
        let note = instruments[selectedInstrument].instrument.note
        instruments[selectedInstrument].instrument.play(noteNumber: note, velocity: 127)
        instruments[selectedInstrument].instrument.stop(noteNumber: note)
    }
    
    func selectInstrument(number: Int){
        if(number < instruments.count){
            if(recordEnabled){
                instruments[selectedInstrument].deselect()
                //update track measure length of instruments in collection if first recording of a track
            }
            prevSelectedInstrument = selectedInstrument
            selectedInstrument = number
            
        }
    }
    
    func addNote(){
        //play note event if not recording
        
        playNote()
        if !recordEnabled || !clickTrack.running {
            print("Record not enabled or pre-record not finished, no add note allowed")
            return
        }
        noteAdded = true
        instruments[selectedInstrument].addNote(127, duration: 0)
        if !playing {
            print("record started play")
            play()
        }
    }
    
    //MARK: update quantize
    func updatePresetQuantize(enabled enable: Bool=true, resolution: Double=1.0){
        if(enable){
            quantizeEnabled = true
            quantizeResolution = resolution
            instruments[selectedInstrument].enableQuantize()
            instruments[selectedInstrument].updateQuantize(resolution)
        }
        else{
            quantizeEnabled = true
            instruments[selectedInstrument].disableQuantize()
        }
    }
    
    //MARK: change measure count of a preset track
    func updatePresetMeasureCount(count: Int){
        instruments[selectedInstrument].trackManager.updateMeasureCount(count)
    }
    
    //MARK: set current preset to mute
    func mutePreset(){
        
        instruments[selectedInstrument].instrument.mute()
    }
    
    func unmutePreset(){
        instruments[selectedInstrument].instrument.unmute()
    }
    
    
    //MARK: set current preset to solo (mute all other preset tracks but keep them looping)
    func enableSoloPreset(){
        for instNum in 0 ..< instruments.count{
            if(instNum != selectedInstrument){
                instruments[instNum].instrument.mute()
            }
            else{
                instruments[instNum].instrument.unmute()
            }
        }
    }
    
    //MARK: unmute all presets
    func disableSoloPreset(){
        
        for instNum in 0 ..< instruments.count{
            instruments[instNum].instrument.unmute()
        }
    }
    
    func start_record(){
        
        if(instruments[selectedInstrument].trackManager.firstInstance){
            //only restart timer if new track otherwise timer should have already been started in the play function
            clickTrack.timer.start()
        }
        instruments[selectedInstrument].record()
        recordEnabled = true
        noteAdded = false
        
        
        
        //now addNote function will add notes to sequences track
    }
    
    
    func record(){
        if !playing {
            print("record cannot start before play")
            return
        }
        if(instruments[selectedInstrument].trackManager.firstInstance){
            //only start preroll if selected preset is empty / has not been recorded
            clickTrack.start_preroll()
        }
        else{
            start_record()
        }
        
    }
    
    func stop_record(){
        recordEnabled = false
        clickTrack.timer.stop()
        for inst in instruments{
            inst.recording = false
            inst.deselect()
        }
        
    }
    
    func play(){
        print("Playing notes of instrument  \(selectedInstrument)")
        //play note in sequence track (just play first track for now)
        //play all recorded tracks
        if(!clickTrack.enabled){
            clickTrack.enable() //run click track but mute it
        }
        
        for inst in instruments{
            inst.instrument.reset()
            inst.trackManager.updateNotePositions() //reset aksequence track and set first note, if any
        }
        playing = true
        clickTrack.timer.start()
        clickTrack.start() //start global multitrack
        
    }
    
    func stop(){
        print("Stop playing instrument  \(selectedInstrument)")
        recordEnabled = false
        //stop all recorded tracks
        clickTrack.stop()
        if(recordEnabled){
            for inst in instruments{
                inst.deselect()
            }
        }
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        stop()
        print("update all instruments with tempo \(newBeatsPerMin)")
        clickTrack.tempo.beatsPerMin = newBeatsPerMin
        clickTrack.update()
        
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        stop()
        print("update all instruments with beats per measure \(newBeatsPerMeasure) and \(newNote) note")
        clickTrack.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        clickTrack.timeSignature.beatUnit = newNote
        clickTrack.update()
        
    }
    

    
    
}
