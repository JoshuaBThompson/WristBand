//
//  Instruments.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

//Testing
class ClickTrackStarterInstrument: SynthInstrument{
    /// Create the synth ClickTrack instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    var sampler: AKSampler!
    var clickTrack: ClickTrack!
    var counts = 0
    var completed = false
    
    init(voiceCount: Int, clickTrackRef: ClickTrack) {
        super.init(instrumentVoice: ClickTrackStarterInstrumentVoice(), voiceCount: voiceCount)
        note = 60
        muted = false
        clickTrack = clickTrackRef
        
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        counts += 1
        if(muted){
            return
        }
        //let volume = velocity/127.0
        //voice.setValue(volume, forKeyPath: "sampler.volume")
        voice.start()
        updateComplete()
        
        
    }
    
    func updateComplete(){
        if(counts >= clickTrack.timeSignature.beatsPerMeasure){
            completed = true
            counts = 0 //reset for next time
            clickTrack.stopPreRecord()
            clickTrack.timer.start()
            clickTrack.start() //now start the clickTrack
            
        }
        else{
            completed = false
        }
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        //voice.stop()
    }
    
}

/****************ClickTrack Instrument
 Desc: This instrument is used by click track
 *****************/

class ClickTrackInstrument: SynthInstrument{
    /// Create the synth ClickTrack instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    var sampler: AKSampler!
    
    init(voiceCount: Int) {
        super.init(instrumentVoice: ClickTrackInstrumentVoice(), voiceCount: voiceCount)
        note = 60
        muted = true
        
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        
        if(muted){
            return
        }
        let volume = velocity/127.0
        voice.setValue(volume, forKeyPath: "sampler.volume")
        voice.start()
        
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stopVoice(voice: AKVoice, note: Int) {
        //voice.stop()
    }
    
}

/// ClickTrack Instrument Voice
class ClickTrackInstrumentVoice: SynthInstrumentVoice{
    
    override init(){
        super.init()
        sampler = AKSampler()
        sampler.loadWav("Sounds/Hat/hat-1")
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = ClickTrackInstrumentVoice()
        return copy
    }
}

/// ClickTrack Instrument Voice
class ClickTrackStarterInstrumentVoice: SynthInstrumentVoice{
    
    override init(){
        super.init()
        sampler = AKSampler()
        sampler.loadWav("Sounds/Hat/hat-3")
        self.avAudioNode = sampler.avAudioNode
    }
    
    override func start() {
        sampler.playNote()
    }
    
    override func stop(){
        //sampler.stopNote()
    }
    
    override func duplicate() -> AKVoice {
        let copy = ClickTrackStarterInstrumentVoice()
        return copy
    }
}


/****************Base class of synth instruments
 ****************/

class SynthInstrument: AKPolyphonicInstrument{
    var note: Int = 0
    var muted = false
    var name = "Synth Instrument"
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
    var sampler: AKSampler!
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



//ClickTrack
class ClickTrack: AKVoice{
    var timer = Timer()
    var midi: AKMIDI!
    var mixer: AKMixer!
    var track: AKSequencer!
    var starterTrack: AKSequencer!
    var starterInstrument: SynthInstrument!
    var starterInstrumentMidi: AKMIDIInstrument!
    var instrument: SynthInstrument!
    var instrumentMidi: AKMIDIInstrument!
    var tempo: Tempo!
    var timeSignature: TimeSignature!
    var _enabled = false
    
    //computed
    var secPerMeasure: Double {return (Double(timeSignature.beatsPerMeasure) / tempo.beatsPerSec) * 4/Double(timeSignature.beatUnit) }
    var secPerClick: Double { return secPerMeasure / Double(timeSignature.beatsPerMeasure) }
    var clickPerSec: Double { return 1/secPerClick }
    var beep: AKOperation!
    var trig: AKOperation!
    var beeps: AKOperation!
    var _running = false
    var running: Bool { return _running}
    var enabled: Bool { return _enabled }
    var muted: Bool { return instrument.muted}
    
    init(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        super.init()
        midi = AKMIDI()
        track = AKSequencer()
        starterTrack = AKSequencer()
        instrument = ClickTrackInstrument(voiceCount: 1)
        starterInstrument = ClickTrackStarterInstrument(voiceCount: 1, clickTrackRef: self)
        tempo = clickTempo
        timeSignature = clickTimeSignature
        mixer = AKMixer()
        mixer.connect(instrument)
        mixer.connect(starterInstrument)
        initInstrumentTrack()
        initStarterIntsrumentTrack()
        self.avAudioNode = mixer.avAudioNode //instrument.avAudioNode
    }
    
    func initInstrumentTrack(){
        instrumentMidi = AKMIDIInstrument(instrument: instrument)
        instrumentMidi.enableMIDI(midi.client, name: "ClickTrack MIDI Instrument")
        
        track.newTrack()
        track.tracks[0].setMIDIOutput(instrumentMidi.midiIn)
        
        
        track.setBPM(Double(tempo.beatsPerMin))
        track.setLength(secPerMeasure)
        //TODO: update the click track setup - this is only for 4/4 time sig
        track.tracks[0].addNote(60, velocity: 127, position: secPerClick*1, duration: 0)
        track.tracks[0].addNote(60, velocity: 105, position: secPerClick*2, duration: 0)
        track.tracks[0].addNote(60, velocity: 105, position: secPerClick*3, duration: 0)
        track.tracks[0].addNote(60, velocity: 105, position: secPerClick*4, duration: 0)
        
    }
    
    func initStarterIntsrumentTrack(){
        starterInstrumentMidi = AKMIDIInstrument(instrument: starterInstrument)
        starterInstrumentMidi.enableMIDI(midi.client, name: "ClickTrack MIDI Starter Instrument")
        
        starterTrack.newTrack()
        starterTrack.tracks[0].setMIDIOutput(starterInstrumentMidi.midiIn)
        
        
        starterTrack.setBPM(Double(tempo.beatsPerMin))
        starterTrack.setLength(secPerMeasure)
        //TODO: update the click track setup - this is only for 4/4 time sig
        starterTrack.tracks[0].addNote(60, velocity: 127, position: secPerClick*1, duration: 0)
        starterTrack.tracks[0].addNote(60, velocity: 105, position: secPerClick*2, duration: 0)
        starterTrack.tracks[0].addNote(60, velocity: 105, position: secPerClick*3, duration: 0)
        starterTrack.tracks[0].addNote(60, velocity: 105, position: secPerClick*4, duration: 0)
    }
    
    func startTimerFromPreRecord(){
        startPreRecord() //starts the pre-record track which will start the clickTrack timer once it finishes one loop
    }
    
    func update(clickTempo: Tempo, clickTimeSignature: TimeSignature){
        print("update click track")
        //update click track freq data
        tempo = clickTempo
        timeSignature = clickTimeSignature
        stop()
        track.setBPM(Double(tempo.beatsPerMin))
        track.setLength(secPerMeasure)
        start()
        //TODO: update track
        
    }
    
    func mute(){
        instrument.muted = true
    }
    
    func unmute(){
        instrument.muted = false
    }
    
    
    //MARK: Enable / Disable used by start() to determine if it should play the track or not
    
    func enable(){
        _enabled = true
    }
    
    func disable(){
        _enabled = false
    }
    
    
    //MARK: overriden functions

    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = ClickTrack(clickTempo: tempo, clickTimeSignature: timeSignature)
        return copy
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return running
    }
    

    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        
        if(_enabled){
            if(!running){
                track.enableLooping()
                track.play()
                _running = true
            }

        }
        else{
            stop()
        }
    }
    
    func startPreRecord(){
        //starts pre-record click track
        starterTrack.rewind()
        starterTrack.enableLooping()
        starterTrack.play()
        
    }
    
    func stopPreRecord(){
        //stops pre-record click track
        starterTrack.stop()
        starterTrack.disableLooping()
    }

    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        track.disableLooping()
        track.rewind()
        track.stop()
        _running = false
    }

}

/* InstrumentTrack
 * Desc:
 *      - Each instrument (like kick preset 1) will have one of these
 *      - Controls the measure count of each track and is responsible for adding notes to track at the right time according to the tempo and time signature
 */

class InstrumentTrack {
    var midi: AKMIDI!
    var trackManager: TrackManager!
    var instrument: SynthInstrument!
    var instrumentMidi: AKMIDIInstrument!
    
    init(clickTrack: ClickTrack, presetInst: SynthInstrument){
        midi = AKMIDI()
        
        trackManager = TrackManager(clickTrackRef: clickTrack)
        instrument = presetInst //custom synth instrument
        
        instrumentMidi = AKMIDIInstrument(instrument: instrument)
        instrumentMidi.enableMIDI(midi.client, name: "Synth inst preset")
        
        trackManager.tracks[0].setMIDIOutput(instrumentMidi.midiIn)
        
    }
    
    func addNote(velocity: Int, duration: Beat){
        let note = instrument.note
        trackManager.addNote(note, velocity: velocity, duration: duration)
        
    }
    
    func deselect(){
        trackManager.deselect() //run deselect routines - for ex: checks if should update measure count (if first time track is recorded)
    }
    
    func play(){
        trackManager.rewind()
        trackManager.enableLooping()
        trackManager.play()
    }
    
    func stop(){
        trackManager.stop()
        trackManager.disableLooping()
        trackManager.rewind()        
    }
    
    
}


/****************Single instrument track manager ********/
class TrackManager: AKSequencer{
    //MARK: Attributes
    var noteCount = 0
    var longestTime: Double = 0.0
    var measureCount = 1000 //default measure count is high initially but will be changed once user adds beats
    var firstInstance = true //informs if this is the first time the track is being filled so we can define the initial measure count / duration
    var clickTrack: ClickTrack!
    var timer: Timer!
    
    //MARK: Computed
    var secPerMeasure: Double { return clickTrack.secPerMeasure }
    var beatsPerMeasure: Int { return clickTrack.timeSignature.beatsPerMeasure }
    var totalBeats: Int { return measureCount * beatsPerMeasure}
    var totalDuration: Double {
        if (longestTime > secPerMeasure*Double(measureCount)){
            //round up to nearest integer to get number of measures
            //if longest time recorded is greater then secPerMeasure then make more measures
            //this might happen if user changes time sig or tempo which may compress or stretch out the track so we need to compensate
            //so we don't lose beats that were made while recording
            measureCount = Int(ceil(Double(longestTime)/Double(secPerMeasure)))
        }

        return secPerMeasure * Double(measureCount)
    }
    var timeElapsed: Double {
        //this gets called when a beat is added to the track
        let timeElapsedSec = timer.stop() //gets the global click track time that is shared with the song / all instruments
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
    
    //MARK: Initialize
    
    init(clickTrackRef: ClickTrack){
        super.init()
        addNewTrack()
        clickTrack = clickTrackRef
        timer = clickTrack.timer
        //set beats per min and total measure count (duration) initially with default value
        updateBPM()
        updateLength()
        
    }
    
    //MARK: Functions
    
    func updateBPM(){
        setBPM(Double(clickTrack.tempo.beatsPerMin))
    }
    
    func updateLength(){
        setLength(totalDuration)
    }
    
    func addNewTrack(){
        if(trackCount > 1){
            print("ERROR: Instrument track should only containt 1 track")
        }
        else{
            self.newTrack()
        }
        
    }
    
    func addNote(note: Int, velocity: Int, duration: Beat){
        if(trackCount >= 1){
            let position = Beat(timeElapsed)
            self.tracks[0].addNote(note, velocity: velocity, position: position, duration: duration)
            noteCount += 1
            //if current track time less that new then replace with new
            longestTime = (longestTime > position) ? position: longestTime
        }
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(firstInstance && noteCount >= 1){
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            measureCount = Int(ceil(timeElapsed / secPerMeasure))
            updateLength()
            firstInstance = false //first instance measure count update complete
        }
        
    }
    
    func clear(){
        if(trackCount >= 1){
            self.tracks[0].clear()
            longestTime = 0.0
            noteCount = 0
        }
    }
    
}



/* InstrumentCollection
 * Desc:
 *     - Contains group of similar instruments (all Snare presets for example)
 *     - Song class deals with this class to record, play and add notes to instrument within a group
 */

class InstrumentCollection {
    //MARK: Attributes
    var instruments = [InstrumentTrack]()
    var midi: AKMIDI!
    var mixer: AKMixer!
    var clickTrack: ClickTrack!
    var instrumentTrack1: InstrumentTrack!
    var instrumentTrack2: InstrumentTrack!
    var instrumentTrack3: InstrumentTrack!
    var instrumentTrack4: InstrumentTrack!
    
    var selectedInst = 0
    var notePosition: Double = 1
    var recordEnabled = false
    var playing = false
    
    //MARK: Computed attributes
    var clickTrackRunning: Bool { return clickTrack.running;}
    var empty: Bool {
        var count = 0
        for inst in instruments{
            count += inst.trackManager.noteCount
        }
        return count == 0
    }
    var trackEmpty: Bool {return instruments[selectedInst].trackManager.noteCount <= 0}
    
    //MARK: Initialization
    init(globalClickTrack: ClickTrack, preset1: SynthInstrument, preset2: SynthInstrument, preset3: SynthInstrument, preset4: SynthInstrument){
        
        // Global click track provided by Song class (which calls this InstrumentPresetTracks class)
        clickTrack = globalClickTrack
        
        // Initialize all presets
        instrumentTrack1 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset1)
        instrumentTrack1.trackManager.addNewTrack()
        instruments.append(instrumentTrack1)
        instrumentTrack2 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset2)
        instrumentTrack2.trackManager.addNewTrack()
        instruments.append(instrumentTrack2)
        instrumentTrack3 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset3)
        instrumentTrack3.trackManager.addNewTrack()
        instruments.append(instrumentTrack3)
        instrumentTrack4 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset4)
        instrumentTrack4.trackManager.addNewTrack()
        instruments.append(instrumentTrack4)
        
        // Connect all instrument sounds in this group of presets to preset mixer
        mixer = AKMixer()
        mixer.connect(instrumentTrack1.instrument)
        mixer.connect(instrumentTrack2.instrument)
        mixer.connect(instrumentTrack3.instrument)
        mixer.connect(instrumentTrack4.instrument)
        
    }
    
    func deselect(){
        for inst in instruments{
            inst.deselect()
        }
    }
    
    
    func selectPreset(preset: Int){
        if(preset < instruments.count){
            if(recordEnabled){
                instruments[selectedInst].deselect() //run previous instrument deselect routine if recording
            }
            selectedInst = preset
        }
    }
    
    func clearPreset(){
        //stop any currently playing tracks first
        stop()
        
        //clear all recorded tracks
        instruments[selectedInst].trackManager.clear()
        
        //start record again
        record()
    }
    func clear(){
        //stop any currently playing tracks first
        stop()
        
        //clear all recorded tracks
        for inst in instruments{
            inst.trackManager.clear()
        }
        
        //start record again
        record()
        
    }
    
    func playNote(presetNumber: Int){
        //play note based on selected instrument preset
        print("Playing preset \(presetNumber) note")
        if(presetNumber < instruments.count){
            let note = instruments[presetNumber].instrument.note;
            instruments[presetNumber].instrument.playNote(note, velocity: 127)
            instruments[presetNumber].instrument.stopNote(note)
        }
        
    }
    
    func addSelectedNote(){
        addNote(preset: selectedInst)
    }
    
    func addNote(preset instNumber: Int){
        //play note event if not recording
        //only add note if record is enabled, otherwise just play it
        selectedInst = instNumber
        playNote(instNumber)
        
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            return
        }
        let velocity = 127
        instruments[instNumber].addNote(velocity, duration: 0) //duration is just how long to hold the beat for if not a pre recorded sample ... I think
        if !playing { play() }
        
    }
    
    func record(){
        print("Recording note")
        recordEnabled = true
    }
    
    func stop_record(){
        recordEnabled = false
        for inst in instruments{
            inst.deselect()
        }
    }
    
    func play(){
        print("Playing notes in sequence track")
        
        for inst in instruments{
            inst.play()
        }
        playing = true
        
    }
    
    func stop(){
        print("Stop playing notes in sequence track")
        if(recordEnabled){
            for inst in instruments{
                inst.deselect()
            }
        }
        recordEnabled = false
        //stop playing note in sequence track
        for inst in instruments{
            inst.stop()
        }
        playing = false
    }
    
    
    func updateTrackTempo(){
        //tell trackManager to update bpm and length based on measure and clickTrack object data
        for inst in instruments{
            inst.trackManager.updateBPM()
            inst.trackManager.updateLength()
        }
    }
    
    
    func updateTrackTimeSignature(){
        //tell trackManager to update length based on time signature defined by measure and clickTrack object data
        for inst in instruments{
            inst.trackManager.updateLength()
        }
    }
    
    
}





