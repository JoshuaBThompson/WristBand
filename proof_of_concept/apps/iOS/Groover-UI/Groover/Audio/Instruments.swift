//
//  Instruments.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

/****************Base class of synth instruments
 ****************/

class SynthInstrument: AKMIDIInstrument{
    var note: Int = 0
    var muted = false
    var instrumentName = "Synth Instrument"
    var sampler = AKSampler()
    var preset = 0
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    override init(){
        super.init()
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        //if not muted then play
        if(!muted){
            sampler.play()
        }
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override func stop(noteNumber noteNumber: MIDINoteNumber) {
        //do something
    }
    
    //mute
    func mute(){
        muted = true
    }
    
    func unmute(){
        muted = false
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
    var beat = 0
    var preRoll = false
    var playTrigger = false
    var clickTrack: ClickTrack!
    var preRollSampler = AKSampler()
    var mixer: AKMixer!
    
    init(clickTrackRef: ClickTrack!) {
        super.init()
        clickTrack = clickTrackRef
        note = 60
        muted = true
        preRollSampler.loadWav("Sounds/Kick/kick-2")
        sampler.loadWav("Sounds/Hat/hat-3")
        mixer = AKMixer()
        mixer.connect(preRollSampler)
        mixer.connect(sampler)
        self.avAudioNode = mixer.avAudioNode //sampler.avAudioNode
        
    }
    
    //this tells click track to start pre roll sound and then tell instruments to start recording on last beat
    func set_record(){
        preRoll = true
    }
    
    //tells click track to start playing instrument from beginning when first beat in click track starts
    func trigger_play(){
        playTrigger = true
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {

        beat+=1
        
        
        var volume = velocity/127.0
        if(preRoll && beat <= 5){
            volume = 127
            if(beat == 5){
                clickTrack.song.start_record()
                preRoll = false
                sampler.volume = muted ? 0: volume
                sampler.play()
            }
            else{
            preRollSampler.volume = volume
            preRollSampler.play()
            }
        }
        else if(playTrigger && beat==5){
            sampler.volume = muted ? 0: volume
            sampler.play()
            clickTrack.song.play()
            playTrigger = false //clear for next use
        }
        else if(!self.muted){
            sampler.volume = volume
            sampler.play()
        }
        if(beat==5){beat=1}
    }
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
class ClickTrack: AKNode{
    var timer = Timer()
    var midi: AKMIDI!
    var track: AKSequencer!
    var instrument: ClickTrackInstrument!
    var tempo: Tempo!
    var timeSignature: TimeSignature!
    var _enabled = false
    var recording = false
    var song: Song!
    
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
    
    init(songRef: Song, clickTempo: Tempo, clickTimeSignature: TimeSignature){
        super.init()
        song = songRef
        midi = AKMIDI()
        track = AKSequencer()
        instrument = ClickTrackInstrument(clickTrackRef: self)
        tempo = clickTempo
        timeSignature = clickTimeSignature
        initInstrumentTrack()
        self.avAudioNode = instrument.avAudioNode
    }
    
    func initInstrumentTrack(){
        instrument.enableMIDI(midi.client, name: "click track midi in")
        
        track.newTrack()
        track.tracks[0].setMIDIOutput(instrument.midiIn)
        
        
        track.setTempo(tempo.beatsPerMin)
        track.setLength(AKDuration(seconds: secPerMeasure))
        print("click track secPerMeasure \(secPerMeasure)")
        //TODO: update the click track setup - this is only for 4/4 time sig
        track.tracks[0].add(noteNumber: 60, velocity: 127, position: AKDuration(seconds: 0), duration: AKDuration(seconds: 0))
        track.tracks[0].add(noteNumber: 60, velocity: 105, position: AKDuration(seconds: 1), duration: AKDuration(seconds: 0))
        track.tracks[0].add(noteNumber: 60, velocity: 105, position: AKDuration(seconds: 2), duration: AKDuration(seconds: 0))
        track.tracks[0].add(noteNumber: 60, velocity: 105, position: AKDuration(seconds: 3), duration: AKDuration(seconds: 0))
        
    }

    
    func update(){
        //tempo.beatsPerMin is updated in Song.swift
        track.setTempo(Double(tempo.beatsPerMin))
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool {
        return running
    }
    

    /// Function to start, play, or activate the node, all do the same thing
    func start_preroll(){
        instrument.set_record()
        enable()
        start()
    }
    
    func trigger_play(){
        instrument.trigger_play()
    }
    
    func start() {
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
    

    /// Function to stop or bypass the node, both are equivalent
    func stop() {
        track.stop()
        track.disableLooping()
        track.rewind()
        
        _running = false
    }

}

/* InstrumentTrack
 * Desc:
 *      - Each instrument (like kick preset 1) will have one of these
 *      - Controls the measure count of each track and is responsible for adding notes to track at the right time according to the tempo and time signature
 */

class InstrumentTrack {
    var trackManager: TrackManager!
    var instrument: SynthInstrument!
    var clickTrack: ClickTrack!
    
    init(clickTrack: ClickTrack, presetInst: SynthInstrument){
        instrument = presetInst //custom synth instrument
        trackManager = TrackManager(midiInstrument: instrument, clickTrackRef: clickTrack)
    }
    
    func addNote(velocity: Int, duration: Double){
        trackManager.addNote(velocity, duration: duration)
        
    }
    
    func deselect(){
        trackManager.deselect() //run deselect routines - for ex: checks if should update measure count (if first time track is recorded)
        if(!trackManager.isPlaying){
            trackManager.clickTrack.trigger_play()
        }
    }
    
    func play(){
        if(trackManager.firstInstance){
            return
        }
        trackManager.rewind()
        trackManager.enableLooping()
        trackManager.play()
    }
    
    func stop(){
        if(trackManager.firstInstance){
            return
        }
        trackManager.stop()
        trackManager.disableLooping()
        trackManager.rewind()
    }
    
    
}


/****************Single instrument track manager ********/
class TrackManager: AKSequencer{
    //MARK: Attributes
    var midi: AKMIDI!
    var trackNotes = [AKDuration]()
    var velNotes = [Int]()
    var durNotes = [AKDuration]()
    var noteCount = 0
    var longestTime: Double = 0.0
    var measureCount = 10 //default measure count is high initially but will be changed once user adds beats
    var firstInstance = true //informs if this is the first time the track is being filled so we can define the initial measure count / duration
    var instrument: SynthInstrument!
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
    
    init(midiInstrument: SynthInstrument, clickTrackRef: ClickTrack){
        super.init()
        midi = AKMIDI()
        instrument = midiInstrument
        clickTrack = clickTrackRef
        timer = clickTrack.timer
        instrument.enableMIDI(midi.client, name: "Synth inst preset")
        updateBPM()
        resetTrack() //creates new track and inits beats per min
        
    }
    
    //MARK: init a track
    func resetTrack(){
        self.tracks.removeAll()
        newTrack()
        tracks[0].setMIDIOutput(instrument.midiIn)
    }
    
    //MARK: Functions
    
    func updateBPM(){
        setTempo(Double(clickTrack.tempo.beatsPerMin))
    }
    
    func updateLength(){
        let wasPlaying = isPlaying
        stop()
        print("inst total duration updated to \(totalDuration)")
        setLength(AKDuration(seconds: totalDuration))
        if(wasPlaying){
            print("was playing")
            enableLooping()
            play()
        }
        
        
    }
    
    
    func addNote(velocity: Int, duration: Double){
        if(trackCount >= 1 && !firstInstance){
            let position = AKDuration(seconds: timeElapsed)
            let note = instrument.note
            self.tracks[0].add(noteNumber: note, velocity: velocity, position: position, duration: AKDuration(seconds: duration))
            noteCount += 1
            //if current track time less that new then replace with new
            longestTime = (longestTime > timeElapsed) ? timeElapsed: longestTime
        }
        else if(trackCount >= 1 && firstInstance){
            print("adding new note to first instance!!!")
            noteCount+=1
            let position = AKDuration(seconds: timeElapsed)
            trackNotes.append(position)
            velNotes.append(velocity)
            durNotes.append(AKDuration(seconds: duration))
        }
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(trackNotes.count >= 1 && firstInstance){
            //hack - audiokit v3.2 since updating length of track doesn't work correctly, need to make new track each time new recording
            resetTrack()
            
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            measureCount = Int(ceil(timeElapsed / secPerMeasure))
            print("inst \(instrument.name) measure count updated to \(measureCount)")
            updateLength()
            for i in 0 ..< trackNotes.count{
                let position = trackNotes[i]
                let velocity = velNotes[i]
                let duration = durNotes[i]
                
                self.tracks[0].add(noteNumber: instrument.note, velocity: velocity, position: position, duration: duration)
            }
            
            firstInstance = false //first instance measure count update complete
        }
        
    }
    
    func clear(){
        if(trackCount >= 1){
            self.tracks[0].clear()
            longestTime = 0.0
            noteCount = 0
            trackNotes.removeAll()
            velNotes.removeAll()
            durNotes.removeAll()
            firstInstance = true
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
        instruments.append(instrumentTrack1)
        instrumentTrack2 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset2)
        instruments.append(instrumentTrack2)
        instrumentTrack3 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset3)
        instruments.append(instrumentTrack3)
        instrumentTrack4 = InstrumentTrack(clickTrack: clickTrack, presetInst: preset4)
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
    
    //MARK: mute all instruments but keep them looping
    func muteAll(){
        for instNum in 0 ..< instruments.count{
            instruments[instNum].instrument.mute()
        }
    }
    
    func unmuteAll(){
        for instNum in 0 ..< instruments.count{
            instruments[instNum].instrument.unmute()
        }
    }
    
    //MARK: solo selected preset and mute all others
    func soloPreset(){
        for instNum in 0 ..< instruments.count{
            if(instNum != selectedInst){
                instruments[instNum].instrument.mute()
            }
            else{
                instruments[instNum].instrument.unmute()
            }
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
        
        //clear preset track
        instruments[selectedInst].trackManager.clear()
        
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
            instruments[presetNumber].instrument.play(noteNumber: note, velocity: 127)
            instruments[presetNumber].instrument.stop(noteNumber: note)
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
        //if !playing { play() }
        
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
            if(!inst.trackManager.isPlaying){
                inst.play()
            }
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
        }
    }
    
    
    func updateTrackTimeSignature(){
        //tell trackManager to update length based on time signature defined by measure and clickTrack object data
        for inst in instruments{
            inst.trackManager.updateLength()
        }
    }
    
    
}





