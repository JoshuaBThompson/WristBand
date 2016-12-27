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
    let maxDivisions = 64.0
    let minDivisions = 1.0
    
    //MARK: quantize a beat pos
    func quantizedBeat(_ beat: AKDuration)->AKDuration{
        let beats = beat.beats
        let divPos = beats * divPerBeat //position in beat divisions (based on quantized number / resolution set by user in UI: ex: 4 or 32)
        let divPosQuantized = round(divPos) //round to nearest division
        let beatsQuantized = divPosQuantized / divPerBeat //get beat position quantized
        
        let posQuantized = AKDuration(beats: beatsQuantized, tempo: beat.tempo)
        return posQuantized
        
    }
    
    //MARK: update the quantization beat divisions
    func update(_ newBeatDivision: Double){
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
    var reset_en = false
    var instTrack: InstrumentTrack!
    var panner: AKPanner!
    var currentNote: AKDuration!
    var beatOffset: Double = 0
    
    //looping
    var ignore = false  // use to ignore specific beat
    var prevQuantPos = AKDuration(beats: 0)
    var realBeatPos = AKDuration(beats: 0)
    var prevRealBeatPos = AKDuration(beats: 0)
    var real_pos: Double = 0
    var note_num: Int = 0
    var loop_count: Int = 0
    var _total_dur: Double = 0
    var _maxNoteCount: Int = 0
    var total_dur_offset: Double = 0
    var measureUpdateReady = false
    var measureUpdateEn = false
    var quantizeEnabled = false
    
    var total_dur: Double {
        if(!measureUpdateReady){
            _total_dur = Double(instTrack.loopLength)
            return _total_dur
        }
        else{
            return _total_dur
        }
    }
    
    var maxNoteCount: Int {
        if(!measureUpdateReady){
            _maxNoteCount = instTrack.maxNoteCount
            return _maxNoteCount
        }
        else{
            return _maxNoteCount
        }
        
    }
    
    var beatPos: Double {
        return instTrack.trackManager.trackNotes[note_num].beats
    }
    
    var realPos: Double {
        return total_dur_offset + beatPos + beatOffset
    }
    
    var beatTempo: Double {
        return instTrack.trackManager.trackNotes[note_num].tempo
    }
    
    var globalTempo: Double {
        return instTrack.trackManager.clickTrack.tempo.beatsPerMin
    }
    
    
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
    
    func reset(){
        note_num = 0
        loop_count = 0
        total_dur_offset = 0
        beatOffset = 0
        prevRealBeatPos = AKDuration(beats: 0)
        prevQuantPos = AKDuration(beats: 0)
        realBeatPos = AKDuration(beats: 0)
        quantizeEnabled = false
    }
    
    func updateNoteNumAndOffset(){
        note_num += 1
        
        if(note_num >= maxNoteCount){
            
            note_num = 0
            if(measureUpdateReady && !measureUpdateEn){
                measureUpdateEn = true
            }
            else if(measureUpdateEn){
                measureUpdateReady = false
                measureUpdateEn = false
            }
            
            total_dur_offset = total_dur_offset + total_dur
        }
    }
    
    func updateRealBeatPos(){
        realBeatPos = AKDuration(beats: realPos, tempo: beatTempo) //beatTempo
    }
    
    func handleQuantize(){
        if(instTrack.trackManager.quantizeEnable){
            quantizeEnabled = true
            
            let quantPos = instTrack.trackManager.quantizer.quantizedBeat(realBeatPos)
            if(quantPos.beats <= prevQuantPos.beats){
                addNote() //keep ignoring note until it's pos is greater than prev pos
                return
            }
            else{
                prevQuantPos = quantPos
            }
        }
        else{
            prevQuantPos = realBeatPos
        }
    }
    
    func addNote(){
        if(instTrack.trackManager.trackNotes.count==0 || instTrack.trackManager.firstInstance){
            return
        }
        
        updateNoteNumAndOffset() //get the current note number in the loop and the total duration offset
        updateRealBeatPos() //get the real note position (original note + offset + time in current loop)
        handleQuantize() //if quantize enabled deal with redundant beats
        
        instTrack.trackManager.insertNote(127, position: realBeatPos, duration: 0)
        //prevRealBeatPos = AKDuration(beats: realBeatPos.beats, tempo: realBeatPos.tempo)
    }
    
    func rawPlay(_ noteNumber: MIDINoteNumber, velocity: MIDIVelocity){
        if(!muted){
            let volume = volumeScale * velocity/127.0
            sampler.volume = volume
            sampler.play()
        }
        
    }
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        addNote()
        if(ignore){
            ignore = false  //ignore specific beat and then reset ignore
            return
        }
        else if(!muted){
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
    override func stop(noteNumber: MIDINoteNumber) {
        //do something
    }
    
    //update volume scale: ex real volume = velocity * scale
    func updateVolume(_ percent: Double){
        volumePercent = percent
    }
    
    func updatePan(_ pan: Double){
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
    var pos: Double = 0
    var preRoll = false
    var preRollEnded = false
    var clickTrack: ClickTrack!
    var preRollSampler = AKSampler()
    var mixer: AKMixer!
    var track: AKSequencer!
    var totalBeats: Double = 0
    
    
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
    
    
    override func reset(){
        beat = 0
        preRollEnded = false
        preRoll = false
        loop_count = 0
        totalBeats = 0
    }
    
    //this tells click track to start pre roll sound and then tell instruments to start recording on last beat
    func set_record(){
        preRoll = true
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        if(beat == 0){
            loop_count += 1
        }
        beat+=1
        pos += 1
        var vel = 100
        if(pos.truncatingRemainder(dividingBy: 4) == 0){
            vel = 127
        }
        
        var volume = velocity/127.0
        if(preRoll && beat <= 4){
            volume = 127
            if(beat == 4){
                preRoll = false
                preRollEnded = true
            }
            preRollSampler.volume = volume
            preRollSampler.play()
            print("preroll \(beat)")
        }
        else if(!self.muted){
            if(preRollEnded){
                clickTrack.song.start_record()
                preRollEnded = false
            }
            
            sampler.volume = volume
            sampler.play()
        }
        else if(preRollEnded){
            clickTrack.song.start_record()
            preRollEnded = false
        }
        if(beat==4){
            beat=0
        }
        
        track.tracks[0].add(noteNumber: 60, velocity: vel, position: AKDuration(beats: Double(pos)), duration: AKDuration(seconds: 0))
        
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
    var baseSecPerMeasure: Double = 4.0
    var beatsPerMeasure = 4 //upper - ex: 4 quarter notes in a measure for a (4/4th)
    var beatUnit = 4 //lower - ex: quarter note (4/4th)
}


//Tempo
class Tempo {
    let maxBeatsPerMin = 200.0
    let minBeatsPerMin = 1.0
    var beatsPerMin = Double(60.0) //60.0
    let secPerMin = Double(60.0)
    var beatsPerSec: Double { return beatsPerMin / secPerMin }
    
    func set_tempo(bpm: Double){
        if(bpm > self.maxBeatsPerMin){
            self.beatsPerMin = self.maxBeatsPerMin
        }
        else if(bpm < self.minBeatsPerMin){
            self.beatsPerMin = self.minBeatsPerMin
        }
        else {
            self.beatsPerMin = bpm
        }
    }
    
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
        init_track_notes()
    }
    
    func init_track_notes(){
        if(track.trackCount != 0){
            //this will erase all the other instrument tracks as well
            track.tracks.removeAll()
        }
        track.newTrack()
        track.tracks[0].setMIDIOutput(instrument.midiIn)
        track.setTempo(tempo.beatsPerMin)
        //track.tracks[0].setLength(AKDuration(beats: Double(timeSignature.beatsPerMeasure), tempo: tempo.beatsPerMin))
        print("click track secPerMeasure \(secPerMeasure)")
        instrument.track = track
        resetTrack()
        
    }
    
    func reset(){
        if(!enabled){
            return
        }
        
        if((track) != nil){
            resetTrack()
            track.rewind()
            track.enableLooping()
            track.play()
        }
    }
    
    func resetTrack(){
        track.stop()
        track.disableLooping()
        track.tracks[0].clear()
        track.tracks[0].add(noteNumber: 60, velocity: 127, position: AKDuration(seconds: 0), duration: AKDuration(seconds: 0))
    }
    
    
    func update(){
        //tempo.beatsPerMin is updated in Song.swift
        track.setTempo(tempo.beatsPerMin)
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
        instrument.reset()
        
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
    var _maxNoteCount: Int = 0
    var clickTrack: ClickTrack!
    var recording = false
    var loopLength: Int {
        return trackManager.measureCount * trackManager.beatsPerMeasure
    }
    var volume: Double {
        return instrument.volumePercent
    }
    
    var pan: Double {
        return instrument.panner.pan
    }
    
    var maxNoteCount: Int {
        let beatCount = trackManager.trackNotes.count
        
        if(beatCount==0){
            _maxNoteCount = 0
        }
        else if(trackManager.trackNotes[beatCount-1].beats > Double(loopLength)){
            _maxNoteCount =  getMaxNoteNum()
        }
        else{
            _maxNoteCount = beatCount
        }
        
        return _maxNoteCount
    }
    
    init(clickTrack: ClickTrack, presetInst: SynthInstrument){
        instrument = presetInst //custom synth instrument
        instrument.instTrack = self
        trackManager = TrackManager(midiInstrument: instrument, clickTrackRef: clickTrack)
    }
    
    func addNote(_ velocity: Int, duration: Double){
        trackManager.addNote(velocity, duration: duration)
    }
    
    func deselect(){
        trackManager.deselect() //run deselect routines - for ex: checks if should update measure count (if first time track is recorded)
    }
    
    
    //MARK: update volume of instrument by changing scale factor 0 - 100%
    func updateVolume(_ percent: Double){
        instrument.updateVolume(percent)
    }
    
    //MARK: update pan (-1 is all left, 0 is center and 1 is all right)
    func updatePan(_ pan: Double){
        instrument.updatePan(pan)
    }
    
    //MARK: update quantized number using resolution of the beat (ex: beat divided into 16 pieces)
    func updateQuantize(_ res: Double){
        //res is the resolution of the beat: ex: 16
        trackManager.quantizer.update(res)
    }
    
    func enableQuantize(){
        trackManager.quantizeEnable = true
    }
    
    func disableQuantize(){
        trackManager.quantizeEnable = false
    }
    
    func record(){
        recording = true
    }
    
    func getMaxNoteNum()->Int{
        var maxNum = trackManager.trackNotes.count-1
        let maxBeatLength = Double(loopLength)
        for noteNum in 0 ..< trackManager.trackNotes.count{
            if(trackManager.trackNotes[noteNum].beats > maxBeatLength){
                maxNum = noteNum
                return maxNum
            }
        }
        
        return maxNum
    }
    
    func updateMeasureCount(_ count: Int){
        
        trackManager.updateMeasureCount(count)
        
        //if playing tell track to wait unitl loop finishes before updating measure count
        if(trackManager.track.isPlaying){
            instrument.measureUpdateReady = true //tells instrument to update measure count in looping after next loop is ready, but not during current loop
        }
    }
    
}


/****************Single instrument track manager ********/
class TrackManager{
    //MARK: Attributes
    var trackNum: Int!
    var track: AKSequencer!
    var quantizeEnable = false
    var quantizer = Quantize()
    var midi: AKMIDI!
    var trackNotes = [AKDuration]()
    var prevPos: AKDuration!
    var velNotes = [Int]()
    var durNotes = [Double]()
    var noteCount = 0
    var measureCount = 1 //default measure count
    var firstInstance = true //informs if this is the first time the track is being filled so we can define the initial measure count / duration
    var instrument: SynthInstrument!
    var clickTrack: ClickTrack!
    var timer: Timer!
    var ignore_count = 0
    
    //MARK: Computed
    var secPerMeasure: Double { return clickTrack.secPerMeasure }
    var beatsPerMeasure: Int { return clickTrack.timeSignature.beatsPerMeasure }
    var totalBeats: Int { return measureCount * beatsPerMeasure}
    var totalDuration: Double {
        
        return secPerMeasure * Double(measureCount)
    }
    var timeElapsedAbs: Double {
        let timeElapsedSec = timer.stop()
        return timeElapsedSec
    }
    
    var isNewRecord: Bool {
        return (trackNotes.count >= 1 && firstInstance)
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
        
        return time
    }
    
    //MARK: Initialize
    
    init(midiInstrument: SynthInstrument, clickTrackRef: ClickTrack){
        midi = AKMIDI()
        instrument = midiInstrument
        clickTrack = clickTrackRef
        track = clickTrack.track
        timer = clickTrack.timer
        prevPos = AKDuration(beats: 0)
        instrument.enableMIDI(midi.client, name: "Synth inst preset")
        trackNum = track.trackCount
        if(track.newTrack() != nil){
            track.tracks[trackNum].setMIDIOutput(instrument.midiIn)
        }
        else{
            print("Could not make track \(trackNum)")
        }
        
    }
    
    //MARK: init a track
    func resetTrack(){
        
        
        prevPos = AKDuration(beats: 0)
        if(track.tracks[trackNum].length != 0){
            let len = track.tracks[trackNum].length
            
            let start = AKDuration(beats: 0, tempo: clickTrack.tempo.beatsPerMin)
            let end = AKDuration(beats: len+1, tempo: clickTrack.tempo.beatsPerMin)
 
            track.tracks[trackNum].clearRange(start: start, duration: end)
        }
        
    }
    
    //MARK: Functions
    
    func insertNote(_ velocity: Int, position: AKDuration, duration: Double){
        var pos = position
        let note = instrument.note
        
        if(quantizeEnable && instrument.quantizeEnabled){
            pos = quantizer.quantizedBeat(pos)
        }
        
        //print("insert track note at \(position.seconds)")
        track.tracks[trackNum].add(noteNumber: note, velocity: velocity, position: pos, duration: AKDuration(seconds: 0))
    }
    
    func addNote(_ velocity: Int, duration: Double){
        let elapsed = timeElapsed
        let absElapsed = timeElapsedAbs
        
        
        
        if(!firstInstance){
            //use relative position
            let position = AKDuration(seconds: elapsed, tempo: clickTrack.tempo.beatsPerMin)
            addNoteToList(velocity, position: position, duration: duration)
        }
        else{
            //use absolute position
            let absPosition = AKDuration(seconds: absElapsed, tempo: clickTrack.tempo.beatsPerMin)
            addNoteToList(velocity, position: absPosition, duration: duration)
        }
    }
    
    func addNoteToList(_ velocity: Int, position: AKDuration, duration: Double){
        noteCount += 1
        trackNotes.append(position)
        velNotes.append(velocity)
        durNotes.append(duration)
        var sortedNotes = [AKDuration]()
        
        sortedNotes = trackNotes.sorted {
            return $0.beats < $1.beats
        }
        //now updates notes list
        trackNotes = sortedNotes
    }
    
    //MARK: Get total measure count from time elapsed and sec per measure
    func getMeasureCountFromTimeElapsed()->Int {
        return Int(ceil(timeElapsedAbs / secPerMeasure))
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(isNewRecord){
            
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            let count = getMeasureCountFromTimeElapsed()
            updateMeasureCount(count)
            updateNotePositions(true)
        }

    }
    
    func updateMeasureCount(_ count: Int){
        //hack - audiokit v3.2 since updating length of track doesn't work correctly, need to make new track each time new recording
        if(count < 1){
            return
        }
        measureCount = count
    }
    
    func updateNotePositions(_ newRecord: Bool = false){
        if(trackNotes.count==0){return}
        firstInstance = false //first instance measure count update complete
        resetTrack()
        var position = trackNotes[0]
        let velocity = velNotes[0]
        let duration = durNotes[0]
        print("update track pos \(position.seconds)")
        if(newRecord){
            print("new record note")
            let beatOffset = Double((clickTrack.instrument.loop_count)*clickTrack.timeSignature.beatsPerMeasure)
            position = AKDuration(beats: position.beats + beatOffset, tempo: position.tempo)
            instrument.beatOffset = beatOffset
        }
        print("insert new note at \(position.seconds)")
        insertNote(velocity, position: position, duration: duration)
        
    }
    
    
    func clear(){
        noteCount = 0
        trackNotes.removeAll()
        velNotes.removeAll()
        durNotes.removeAll()
        firstInstance = true
        measureCount = 1
        resetTrack()
        instrument.reset()
        prevPos = AKDuration(beats: 0)
    }
    
}







