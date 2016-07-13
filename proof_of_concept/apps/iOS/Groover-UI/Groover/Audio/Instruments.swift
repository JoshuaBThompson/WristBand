//
//  Instruments.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

/****************Custom AKSequencer
 *********/

class Track: AKSequencer{
    var trackNotesCount = [Int]()
    var trackTimes = [Double]()
    var noteCount: Int {
        var count = 0
        for i in 0 ..< trackNotesCount.count {
            count = count + trackNotesCount[i]
        }
        return count
    }
    
    var longestTime: Double {
        var currentTime: Double = 0
        for trackNum in 0 ..< trackCount {
            if(trackTimes[trackNum] > currentTime){
                currentTime = trackTimes[trackNum]
            }
        }
        return currentTime
    }
    
    func addNewTrack(){
        self.newTrack()
        trackNotesCount.append(0)
        trackTimes.append(0) //holds max track time elapsed
        
    }
    
    func addNote(trackNum: Int, note: Int, velocity: Int, position: Beat, duration: Beat){
        self.tracks[trackNum].addNote(note, velocity: velocity, position: position, duration: duration)
        trackNotesCount[trackNum] += 1
        //if current track time less that new then replace with new
        trackTimes[trackNum] = (trackTimes[trackNum] > position) ? position: trackTimes[trackNum]
    }
    
    func clear(){
        for trackNum in 0 ..< trackCount {
            tracks[trackNum].clear()
            trackNotesCount[trackNum] = 0
            trackTimes[trackNum] = 0
        }
    }
    
    func clearTrack(trackNum: Int){
        if(trackNum < tracks.count){
            tracks[trackNum].clear()
            trackNotesCount[trackNum] = 0
            trackTimes[trackNum] = 0
        }
        //TODO: track note count for each track
    }
}


/****************Base class of synth instruments
 ****************/

class SynthInstrument: AKPolyphonicInstrument{
    var note: Int = 0
    
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    init(instrumentVoice: SynthInstrumentVoice, voiceCount: Int){
        super.init(voice: instrumentVoice, voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        voice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        voice.stop()
    }
}

/****************Base class for synth instrument voices
*****************/

class SynthInstrumentVoice: AKVoice{
    var preset = 0
}




//Timer

class Timer {
    
    var startTime:CFAbsoluteTime
    var endTime:CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func start(){
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        
        return duration!
    }
    
    var duration:CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}

//Time Signature

struct TimeSignature {
    var beatsPerMeasure = 4 //upper - ex: 4 quarter notes in a measure for a (4/4th)
    var beatUnit = 4 //lower - ex: quarter note (4/4th)
}


//Tempo

struct Tempo {
    var beatsPerMin = Double(60.0)
    let secPerMin = Double(60.0)
    var beatsPerSec: Double { return beatsPerMin / secPerMin }
}



//Measure
class Measure {
    var timeSignature = TimeSignature()
    var tempo = Tempo()
    var clickTrack: ClickTrack!
    var timer = Timer()
    var count = 1
    var longestTime = 0.0
    
    //computed
    var secPerMeasure: Double { return clickTrack.secPerMeasure }
    var beatsPerMeasure: Int { return timeSignature.beatsPerMeasure }
    var totalBeats: Int { return count * beatsPerMeasure}
    var totalDuration: Double {
        if (longestTime > secPerMeasure){
            //round up to nearest integer to get number of measures
            //if longest time recorded is greater then secPerMeasure then make more measures
            //so we don't lose beats that were made while recording
            count = Int(ceil(Double(longestTime)/Double(secPerMeasure)))
        }
        else{
            count = 1; //todo: how should we update measure counts?
        }
        return secPerMeasure * Double(count)
    }
    var timeElapsed: Double {
        //this gets called when a beat is added to the track
        let timeElapsedSec = timer.stop()
        var time = 0.0
        if timeElapsedSec <= totalDuration {
            time = timeElapsedSec
        }
        else{
            time = fmod(timeElapsedSec, totalDuration)
        }
        if longestTime < time {
            //this will record when a beat was added (gets the longest time beat)
            longestTime = time
        }
        
        return time
        
    }
    
    init(){
        clickTrack = ClickTrack(clickTempo: tempo, clickTimeSignature: timeSignature)
    }
    
    
}

//ClickTrack
class ClickTrack: AKVoice{
    var tempo: Tempo!
    var timeSignature: TimeSignature!
    var clickOperation: AKOperation!
    var clickGenerator: AKOperationGenerator!
    
    //computed
    var secPerMeasure: Double {return Double(timeSignature.beatsPerMeasure) / tempo.beatsPerSec * 4/Double(timeSignature.beatUnit) }
    var secPerClick: Double { return secPerMeasure / Double(timeSignature.beatsPerMeasure) }
    var clickPerSec: Double { return 1/secPerClick }
    var beep: AKOperation!
    var trig: AKOperation!
    var beeps: AKOperation!
    var _running = false
    var running: Bool { return _running;}
    
    init(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        super.init()
        tempo = clickTempo
        timeSignature = clickTimeSignature
        
        beep = AKOperation.sineWave(frequency: 480)
        
        trig = AKOperation.metronome(AKOperation.parameters(0))
        
        beeps = beep.triggeredWithEnvelope(
            trig,
            attack: 0.01, hold: 0, release: 0.01)
        
        clickGenerator = AKOperationGenerator(operation: beeps)
        clickGenerator.parameters = [clickPerSec]
        self.avAudioNode = clickGenerator.avAudioNode
        //clickGenerator.start()
    }
    
    func update(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        print("update click track")
        //update click track freq data
        tempo = clickTempo
        timeSignature = clickTimeSignature
        clickGenerator.parameters = [clickPerSec] // clickPerSec is computed var that used updated tempo and timeSignature
        
    }
    
    //MARK: functions

    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = ClickTrack(clickTempo: tempo, clickTimeSignature: timeSignature)
        return copy
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        let playing: Bool = clickGenerator.isPlaying
        return playing
    }

    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        clickGenerator.start()
        _running = true
        
    }

    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        clickGenerator.stop()
        _running = false
    }

}



class InstrumentPresetTracks {
    var instruments = [SynthInstrument]()
    var midi: AKMIDI!
    var mixer: AKMixer!
    var measure: Measure!
    var trackManager: Track!
    
    var selectedInst = 0
    var instPreset1: SynthInstrument!
    var instPreset2: SynthInstrument!
    var instPreset3: SynthInstrument!
    var instPreset4: SynthInstrument!
    var preset1Midi: AKMIDIInstrument!
    var preset2Midi: AKMIDIInstrument!
    var preset3Midi: AKMIDIInstrument!
    var preset4Midi: AKMIDIInstrument!
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    var clickTrackRunning: Bool { return measure.clickTrack.running;}
    var empty: Bool { return trackManager.noteCount > 0}
    
    init(preset1: SynthInstrument, preset2: SynthInstrument, preset3: SynthInstrument, preset4: SynthInstrument){
        midi = AKMIDI()
        trackManager = Track()
        measure = Measure()
        instPreset1 = preset1 //custom synth instrument with preset1
        instruments.append(instPreset1)
        instPreset2 = preset2 //custom synth instrument with preset2
        instruments.append(instPreset2)
        instPreset3 = preset3 //custom synth instrument with preset3
        instruments.append(instPreset3)
        instPreset4 = preset4 //custom synth instrument with preset4
        instruments.append(instPreset4)
        
        mixer = AKMixer()
        mixer.connect(instPreset1)
        mixer.connect(instPreset2)
        mixer.connect(instPreset3)
        mixer.connect(instPreset4)
        mixer.connect(measure.clickTrack)
    
        preset1Midi = AKMIDIInstrument(instrument: instPreset1)
        preset1Midi.enableMIDI(midi.client, name: "Synth inst preset 1")
        preset2Midi = AKMIDIInstrument(instrument: instPreset2)
        preset2Midi.enableMIDI(midi.client, name: "Synth inst preset 2")
        preset3Midi = AKMIDIInstrument(instrument: instPreset3)
        preset3Midi.enableMIDI(midi.client, name: "Synth inst preset 3")
        preset4Midi = AKMIDIInstrument(instrument: instPreset4)
        preset4Midi.enableMIDI(midi.client, name: "Synth inst preset 4")
        
        trackManager.addNewTrack()
        trackManager.tracks[0].setMIDIOutput(preset1Midi.midiIn)
        trackManager.addNewTrack()
        trackManager.tracks[1].setMIDIOutput(preset2Midi.midiIn)
        trackManager.addNewTrack()
        trackManager.tracks[2].setMIDIOutput(preset3Midi.midiIn)
        trackManager.addNewTrack()
        trackManager.tracks[3].setMIDIOutput(preset4Midi.midiIn)
        
        trackManager.setBPM(Double(measure.clickTrack.tempo.beatsPerMin))
        trackManager.setLength(measure.totalDuration)
        
        print(String(format: "sequence bpm %f", measure.clickTrack.tempo.beatsPerMin))
        print(String(format: "sequence length %f", measure.totalDuration))        
        
    }
    
    func startClickTrack(){
        measure.clickTrack.start()
    }
    
    func stopClickTrack(){
        measure.clickTrack.stop()
    }
    
    func clearPreset(){
        //stop any currently playing tracks first
        stop()
        measure.longestTime = trackManager.longestTime //get new longest time
        
        //clear all recorded tracks
        trackManager.clearTrack(selectedInst)
        
        //start record again
        record()
    }
    func clear(){
        //stop any currently playing tracks first
        stop()
        measure.longestTime = 0.0 //clear
        
        //clear all recorded tracks
        trackManager.clear()
        
        //start record again
        record()
        
    }
    
    func playNote(presetNumber: Int){
        //play note based on selected instrument preset
        print("Playing preset \(presetNumber) note")
        if(presetNumber < instruments.count){
            let note = instruments[presetNumber].note;
            instruments[presetNumber].playNote(note, velocity: 127)
            instruments[presetNumber].stopNote(note)
        }
        
    }
    
    func addSelectedNote(){
        addNote(preset: selectedInst)
    }
    
    func addNote(preset instNumber: Int){
        //play note event if not recording
        selectedInst = instNumber
        playNote(instNumber)
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            return
        }
        let note = instruments[instNumber].note
        //only add note if record is enabled, otherwise just play it
        //add note to current track
        //todo: input to function should a note with vel, note value
        //todo: next add note to current track based on selected instrument (not yet developed)
        let timeElapsed = measure.timeElapsed
        print(String(format: "Time elapsed %f", timeElapsed))
        trackManager.addNote(instNumber, note: note, velocity: 127, position: timeElapsed, duration: 0)
        if !playing { play() }
        
    }
    
    func record(){
        print("Recording note")
        recordEnabled = true
        measure.timer.start()
        //now addNote function will add notes to sequences track
    }
    
    func play(){
        print("Playing notes in sequence track")
        //play note in sequence track (just play first track for now)
        trackManager.enableLooping()
        trackManager.play()
        playing = true
        
    }
    
    func stop(){
        print("Stop playing notes in sequence track")
        recordEnabled = false
        //stop playing note in sequence track
        trackManager.disableLooping()
        trackManager.stop()
        measure.timer.stop()
        playing = false
    }
    
    func setTempo(newBeatsPerMin: Double){
        pause()
        measure.tempo.beatsPerMin = newBeatsPerMin
        print("todo: click track update tempo")
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        trackManager.setBPM(Double(measure.clickTrack.tempo.beatsPerMin))
        trackManager.setLength(measure.totalDuration)
        unpause()
    }
    
    
    func setTimeSignature(newBeatsPerMeasure: Int, newNote: Int){
        pause()
        measure.timeSignature.beatsPerMeasure = newBeatsPerMeasure
        measure.timeSignature.beatUnit = newNote
        measure.clickTrack.update(measure.tempo, clickTimeSignature: measure.timeSignature)
        trackManager.setLength(measure.totalDuration)
        print("track manager length \(trackManager.length)")
        unpause()
        
    }
    
    func pause(){
        if(playing){
            trackManager.stop()
            trackManager.disableLooping()
        }
    }
    
    func unpause(){
        if(playing){
            trackManager.enableLooping()
            trackManager.play()
        }
    }
    
    
}





