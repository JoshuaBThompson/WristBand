//
//  Instruments.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 5/7/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import Foundation
import AudioKit

/****************Quantize*******************/
class Quantize {
    var divPerBeat = 1.0 //divisions per beat (beat resolution, ex: 64 divisions would be highest resolution and 1 is lowest)
    var bpm = 60.0
    var secPerMin = 60.0
    let maxDivisions = 64.0
    let minDivisions = 1.0
    
    //MARK: computed variables
    var beatPerSec: Double {
        return bpm / secPerMin
    }
    
    //MARK: get beat position from time in sec
    func getBeatPosFromSec(sec: Double)->Double{
        let beatPos = sec * beatPerSec
        return beatPos
    }
    
    //MARK: get beat position in beat divisions (ex: beat pos of 2 would be 2*16 if beat resolution = 16 divisions)
    func getDivPosFromSec(sec: Double)->Double{
        let beatPos = getBeatPosFromSec(sec)
        let divPos = beatPos * divPerBeat //position in beat divisions
        return divPos
    }
    
    //MARK: get quantized division (round up or down to neart division)
    func getQuantizedDivPosFromSec(sec: Double)->Double{
        let divPosRaw = getDivPosFromSec(sec)
        let divPosQuantized = round(divPosRaw)
        return divPosQuantized
    }
    
    //MARK: convert quantized divisions to beat position
    func getBeatPosFromDiv(divPos: Double)->Double{
        let beatPos = divPos / divPerBeat
        return beatPos
    }
    
    func getSecPosBeatPos(beatPos: Double)->Double{
        return beatPos / beatPerSec
    }
    
    //MARK: get quantized position from time pos in seconds
    func quantized(sec: Double)->Double{
        let quantizedDivPos = getQuantizedDivPosFromSec(sec)
        let quantizedBeatPos = getBeatPosFromDiv(quantizedDivPos)
        let quantizedSecPos = getSecPosBeatPos(quantizedBeatPos)
        return quantizedSecPos
    }
    
    //MARK: update the quantization beat divisions
    func update(newBeatDivision: Double){
        var div = newBeatDivision
        
        //enforce max and min beat resolution
        if(div > maxDivisions){
            div = maxDivisions
        }
        else if(div < minDivisions){
            div = minDivisions
        }
        
        divPerBeat = div
    }
}


/****************Base class of synth instruments
 ****************/

class SynthInstrument: AKMIDIInstrument{
    var note: Int = 0
    var muted = false
    var volumePercent: Double = 100.0
    var instrumentName = "Synth Instrument"
    var sampler = AKSampler()
    var preset = 0
    var panner: AKPanner!
    var volumeScale: Double {
        return volumePercent/100.0
    }
    /// Create the synth snare instrument
    ///
    /// - parameter voiceCount: Number of voices (usually two is plenty for drums)
    ///
    override init(){
        super.init()
        panner = AKPanner(sampler, pan: 0)
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
            let volume = volumeScale * velocity/127.0
            sampler.volume = volume
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
    
    //update volume scale: ex real volume = velocity * scale
    func updateVolume(percent: Double){
        volumePercent = percent
    }
    
    func updatePan(pan: Double){
        //-1 is completely left pan, 0 is center and 1 is compeletely right pan
        
        //pan range limits
        var newPan = pan
        if(newPan > 1.0){newPan = 1.0}
        else if(newPan < -1.0){newPan = -1.0}
        
        panner.pan = newPan
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
    
    var volume: Double {
        return instrument.volumePercent
    }
    
    var pan: Double {
        return instrument.panner.pan
    }
    
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
    
    //MARK: update volume of instrument by changing scale factor 0 - 100%
    func updateVolume(percent: Double){
        instrument.updateVolume(percent)
    }
    
    //MARK: update pan (-1 is all left, 0 is center and 1 is all right)
    func updatePan(pan: Double){
        instrument.updatePan(pan)
    }
    
}


/****************Single instrument track manager ********/
class TrackManager: AKSequencer{
    //MARK: Attributes
    var quantizer = Quantize()
    var midi: AKMIDI!
    var trackNotes = [AKDuration]()
    var velNotes = [Int]()
    var durNotes = [AKDuration]()
    var noteCount = 0
    var longestTime: Double = 0.0
    var measureCount = 1 //default measure count
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
    var timeElapsedAbs: Double {
        let timeElapsedSec = timer.stop()
        return timeElapsedSec
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
        if(trackCount >= 1){
            self.tracks[0].clear()
        }
        self.tracks.removeAll()
        newTrack()
        tracks[0].setMIDIOutput(instrument.midiIn)
    }
    
    //MARK: Functions
    
    func updateBPM(){
        setTempo(Double(clickTrack.tempo.beatsPerMin))
    }
    
    func updateLength(){
        print("inst total duration updated to \(totalDuration)")
        setLength(AKDuration(seconds: totalDuration))
    }
    
    
    func addNote(velocity: Int, duration: Double){
        let position = AKDuration(seconds: timeElapsed)
        let absPosition = AKDuration(seconds: timeElapsedAbs)
        let note = instrument.note
        if(trackCount >= 1 && !firstInstance){
            print("adding note to track")
            addNoteToList(velocity, position: position, duration: duration)
            addNoteToTrack(note, velocity: velocity, position: position, duration: duration)
        }
        else if(firstInstance){
            print("adding new note to first instance!!!")
            addNoteToList(velocity, position: absPosition, duration: duration)
        }
    }
    
    func addNoteToList(velocity: Int, position: AKDuration, duration: Double){
        noteCount += 1
        trackNotes.append(position)
        velNotes.append(velocity)
        durNotes.append(AKDuration(seconds: duration))
    }
    
    func addNoteToTrack(note: Int, velocity: Int, position: AKDuration, duration: Double){
        addNoteToList(velocity, position: position, duration: duration)
        self.tracks[0].add(noteNumber: note, velocity: velocity, position: position, duration: AKDuration(seconds: duration))
        //if current track time less that new then replace with new
        longestTime = (longestTime > timeElapsed) ? timeElapsed: longestTime
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(trackNotes.count >= 1 && firstInstance){
            
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            let count = Int(ceil(timeElapsedAbs / secPerMeasure))
            updateMeasureCount(count)
        }
        
    }
    
    func updateMeasureCount(count: Int){
        let wasPlaying = isPlaying
        if(isPlaying){
            stop()
            disableLooping()
        }
        //hack - audiokit v3.2 since updating length of track doesn't work correctly, need to make new track each time new recording
        print("inst \(instrument.name) measure count updated to \(count)")
        measureCount = count
        
        resetTrack()
        updateLength()
        for i in 0 ..< trackNotes.count{
            let position = trackNotes[i]
            let velocity = velNotes[i]
            let duration = durNotes[i]
            let maxTime = AKDuration(seconds: totalDuration)
            if(position <= maxTime){
                self.tracks[0].add(noteNumber: instrument.note, velocity: velocity, position: position, duration: duration)
            }
        }
        
        firstInstance = false //first instance measure count update complete
        
        if(wasPlaying){
            enableLooping()
            play()
        }
        
    }
    
    func clear(){
        if(trackCount >= 1){
            stop()
            disableLooping()
            self.tracks[0].clear()
            resetTrack()
            longestTime = 0.0
            noteCount = 0
            trackNotes.removeAll()
            velNotes.removeAll()
            durNotes.removeAll()
            firstInstance = true
            measureCount = 1
            setLength(AKDuration(beats: Double(measureCount)))
        }
    }
    
    //MARK: Quantize beats
    func quantizeBeats(){

        resetTrack() //current measure count will not be cleared
        updateLength() //using current measure count
        
        for i in 0 ..< trackNotes.count{
            let position: AKDuration = trackNotes[i]
            let quantizedPos = AKDuration(seconds: quantizer.quantized(position.seconds))
            let velocity = velNotes[i]
            let duration = durNotes[i]
            let maxTime = AKDuration(seconds: totalDuration)
            if(position <= maxTime){
                self.tracks[0].add(noteNumber: instrument.note, velocity: velocity, position: quantizedPos, duration: duration)
            }
        }
        
        firstInstance = false //first instance measure count update complete
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
    var presetVolume: Double {return instruments[selectedInst].volume}
    var presetPan: Double {return instruments[selectedInst].pan}
    
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
        mixer.connect(instrumentTrack1.instrument.panner)
        mixer.connect(instrumentTrack2.instrument.panner)
        mixer.connect(instrumentTrack3.instrument.panner)
        mixer.connect(instrumentTrack4.instrument.panner)
        
    }
    
    func deselect(){
        for inst in instruments{
            inst.deselect()
        }
    }
    
    //MARK: update preset pan (-1 left, 0 center, 1 right and everything else in between)
    func updatePresetPan(pan: Double){
        instruments[selectedInst].updatePan(pan)
    }
    
    
    func decPresetPan(){
        let currentPan = presetPan
        
        //decrease volume by 1% (out of 100%)
        updatePresetPan(currentPan - 0.1)
    }
    
    func incPresetPan(){
        let currentPan = presetPan
        
        //increase volume by 1% (out of 100%)
        updatePresetPan(currentPan + 0.1)
    }
    
    //MARK: update preset volume (percent 0 - 100%)
    func updatePresetVolume(percent: Double){
        //select volume 0-100% ( corresponds to midi velocity 0 - 127 )
        var vol = percent
        
        //make sure volume within range
        if(vol >= 100.0){vol = 100.0}
        if(vol < 0.0){vol = 0.0}
        
        //now all volume of notes heard for preset will be amplified or decreased by scale factor
        instruments[selectedInst].updateVolume(vol)
        
    }
    
    func decPresetVolume(){
        let currentVol = presetVolume
        
        //decrease volume by 1% (out of 100%)
        updatePresetVolume(currentVol-1)
    }
    
    func incPresetVolume(){
        let currentVol = presetVolume
        
        //increase volume by 1% (out of 100%)
        updatePresetVolume(currentVol+1)
    }
    
    //MARK: update preset measure count
    func updatePresetMeasureCount(count: Int){
        instruments[selectedInst].trackManager.updateMeasureCount(count)
    }
    
    //MARK: mute preset only
    func mutePreset(){
        instruments[selectedInst].instrument.mute()
    }
    
    func unmutePreset(){
        instruments[selectedInst].instrument.unmute()
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





