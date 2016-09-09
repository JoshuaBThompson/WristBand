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
    var reset_en = false
    var instTrack: InstrumentTrack!
    var panner: AKPanner!
    var currentNote: AKDuration!
    
    //looping
    var pos: Double = 0
    var real_pos: Double = 0
    var note_num: Int = 0
    var loop_count: Int = 0

    var total_dur: Double {
        return instTrack.trackManager.measureCount * instTrack.trackManager.beatsPerMeasure
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
        pos = 0
        note_num = 0
        loop_count = 0
    }
    
    func addNote(){
        print("adding note kick 1!!!!")
        if(instTrack.trackManager.trackNotes.count==0 || instTrack.trackManager.firstInstance){
            return
        }
        
        //get next note position
        //increment note index
        
        note_num += 1
        
        if(note_num >= instTrack.trackManager.trackNotes.count){
            note_num = 0
            loop_count += 1
            print("reset note add")
        }
        print("note_num set to \(note_num)")
        pos = instTrack.trackManager.trackNotes[note_num].beats
        real_pos = (loop_count * total_dur) + pos
        
        print("pos \(pos) and real_pos \(real_pos)")
        let tempo = instTrack.trackManager.trackNotes[note_num].tempo
        currentNote = AKDuration(beats: real_pos, tempo: tempo)
        instTrack.trackManager.insertNote(127, position: currentNote, duration: 0)
    }
    
    func rawPlay(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity){
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
    override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        addNote()
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
    var preRollEnded = false
    var playTrigger = false
    var clickTrack: ClickTrack!
    var preRollSampler = AKSampler()
    var mixer: AKMixer!
    var track: AKSequencer!
    
    
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
        playTrigger = false
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
        var reset = false
        beat+=1
        pos += 1
        var vel = 100
        if(pos % 4 == 0){
            vel = 127
        }
        //track.tracks[0].add(noteNumber: 60, velocity: vel, position: AKDuration(beats: Double(pos)), duration: AKDuration(seconds: 0))
        
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
        else if(playTrigger && beat == 1){
            
            playTrigger = false //clear for next use
            //sampler.volume = muted ? 0: volume
            //sampler.play()
            pos = 0
            reset = true
            clickTrack.reset()
            
            
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
        
        if(!reset){
            track.tracks[0].add(noteNumber: 60, velocity: vel, position: AKDuration(beats: Double(pos)), duration: AKDuration(seconds: 0))
        }
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
struct Tempo {
    var beatsPerMin = Double(60.0) //60.0
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
    var clickTrack: ClickTrack!
    var recording = false
    
    var volume: Double {
        return instrument.volumePercent
    }
    
    var pan: Double {
        return instrument.panner.pan
    }
    
    init(clickTrack: ClickTrack, presetInst: SynthInstrument){
        instrument = presetInst //custom synth instrument
        instrument.instTrack = self
        trackManager = TrackManager(midiInstrument: instrument, clickTrackRef: clickTrack)
    }
    
    func addNote(velocity: Int, duration: Double){
        trackManager.addNote(velocity, duration: duration)
    }
    
    func deselect(){
        trackManager.deselect() //run deselect routines - for ex: checks if should update measure count (if first time track is recorded)
        
        /*
        if(trackManager.track.isPlaying){
            trackManager.clickTrack.trigger_play()
        }
        */
        
    }
    
    
    //MARK: update volume of instrument by changing scale factor 0 - 100%
    func updateVolume(percent: Double){
        instrument.updateVolume(percent)
    }
    
    //MARK: update pan (-1 is all left, 0 is center and 1 is all right)
    func updatePan(pan: Double){
        instrument.updatePan(pan)
    }
    
    //MARK: update quantized number using resolution of the beat (ex: beat divided into 16 pieces)
    func updateQuantize(res: Double){
        //res is the resolution of the beat: ex: 16
        trackManager.quantizer.update(res)
    }
    
    func enableQuantize(){
        trackManager.quantizeEnable = true
    }
    
    func disableQuantize(){
        trackManager.quantizeEnable = false
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
    var velNotes = [Int]()
    var durNotes = [Double]()
    var noteCount = 0
    var longestTime: Double = 0.0
    var measureCount = 1 //default measure count
    var firstInstance = true //informs if this is the first time the track is being filled so we can define the initial measure count / duration
    var instrument: SynthInstrument!
    var clickTrack: ClickTrack!
    var timer: Timer!
    var new = false
    
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
        midi = AKMIDI()
        instrument = midiInstrument
        clickTrack = clickTrackRef
        track = clickTrack.track
        trackNum = track.trackCount
        timer = clickTrack.timer
        instrument.enableMIDI(midi.client, name: "Synth inst preset")
        track.newTrack()
        track.tracks[trackNum].setMIDIOutput(instrument.midiIn)
        
    }
    
    //MARK: init a track
    func resetTrack(){
        if(track.tracks[trackNum].length != 0){
            let len = track.tracks[trackNum].length
            let start = AKDuration(beats: 0, tempo: clickTrack.tempo.beatsPerMin)
            let end = AKDuration(beats: len+1, tempo: clickTrack.tempo.beatsPerMin)
            print("resetting track length \(len)")
            track.tracks[trackNum].clearRange(start: start, duration: end)
        }
    }
    
    //MARK: Functions
    func updateLength(){
    }
    
    func insertNote(velocity: Int, position: AKDuration, duration: Double){
        //quantizer.bpm = 60.0//clickTrack.tempo.beatsPerMin
        let pos = position//AKDuration(beats: beatPos)
        let note = instrument.note
        track.tracks[trackNum].add(noteNumber: note, velocity: velocity, position: pos, duration: AKDuration(seconds: duration))
    }
    
    func addNote(velocity: Int, duration: Double){
        let elapsed = timeElapsed
        let position = AKDuration(seconds: elapsed, tempo: clickTrack.tempo.beatsPerMin)
        let absElapsed = timeElapsedAbs
        let absPosition = AKDuration(seconds: absElapsed, tempo: clickTrack.tempo.beatsPerMin)
        if(!firstInstance){
            print("adding note to track at \(elapsed)")
            addNoteToList(velocity, position: position, duration: duration)
            //addNoteToTrack(note, velocity: velocity, position: position, duration: duration)
        }
        else if(firstInstance){
            print("adding new note at \(absElapsed)")
            addNoteToList(velocity, position: absPosition, duration: duration)
        }
    }
    
    func addNoteToList(velocity: Int, position: AKDuration, duration: Double){
        noteCount += 1
        trackNotes.append(position)
        velNotes.append(velocity)
        durNotes.append(duration)
        let sortedNotes = trackNotes.sort {
            return $0.beats < $1.beats
        }
        //now updates notes list
        trackNotes = sortedNotes
    }
    
    func addNoteToTrack(note: Int, velocity: Int, position: AKDuration, duration: Double){
        addNoteToList(velocity, position: position, duration: duration)
        //insertNote(note, velocity: velocity, position: position, duration: duration)
        //if current track time less that new then replace with new
        longestTime = (longestTime > timeElapsed) ? timeElapsed: longestTime
    }
    
    //MARK: deselect instrument track - do anything that needs to be done after user stops using this track
    func deselect(){
        if(trackNotes.count >= 1 && firstInstance){
            new = true
            
            //If this is the first time the track is being created then update measure count after instrument record stopped / deselected
            //measure count = roundUp(timeElapsed (sec) / secPerMeasure) roundUp = ceil math function
            //for ex: if timeElapsed = 9 sec and sec per measure = 4 then measure count = ceil(9/4) = 2.25 = 3 measure counts
            
            let count = Int(ceil(timeElapsedAbs / secPerMeasure))
            print("deselect update count \(count) and secPerMeasure \(secPerMeasure)")
            updateMeasureCount(count)
            updateNotePositions()
        }
        else{
            new = false
        }
        
    }
    
    func updateMeasureCount(count: Int){
        //hack - audiokit v3.2 since updating length of track doesn't work correctly, need to make new track each time new recording
        print("inst \(instrument.name) measure count updated to \(count)")
        measureCount = count
    }
    
    func updateNotePositions(){
        if(trackNotes.count==0){return}
        
        if(quantizeEnable){
            quantizeBeats()
        }
        else{
            resetTrack()
                //quantizer.bpm = 60.0//clickTrack.tempo.beatsPerMin
                let position = trackNotes[0]
                let velocity = velNotes[0]
                let duration = AKDuration(seconds: durNotes[0])
                let maxTime = totalDuration
                print("update track pos \(position.seconds)")
                if(position.seconds <= maxTime){
                    track.tracks[trackNum].add(noteNumber: instrument.note, velocity: velocity, position: position, duration: duration)
                }
            
            
            updateLength()
        }
        
        firstInstance = false //first instance measure count update complete
    }
    
    
    func clear(){
            longestTime = 0.0
            noteCount = 0
            trackNotes.removeAll()
            velNotes.removeAll()
            durNotes.removeAll()
            firstInstance = true
            measureCount = 1
            updateLength()
            resetTrack()
            instrument.reset()
    }
    
    //MARK: Quantize beats
    func quantizeBeats(){
        print("Quantize!!!")
        resetTrack() //current measure count will not be cleared
        updateLength() //using current measure count
        
        for i in 0 ..< trackNotes.count{
            let position = trackNotes[i]
            let quantizedPos = AKDuration(seconds: quantizer.quantized(position.seconds))
            let velocity = velNotes[i]
            let duration = AKDuration(seconds: durNotes[i])
            let maxTime = AKDuration(seconds: totalDuration)
            if(position <= maxTime && i == 0){
                track.tracks[trackNum].add(noteNumber: instrument.note, velocity: velocity, position: quantizedPos, duration: duration)
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
    var new: Bool {
        for inst in instruments{
            if(inst.trackManager.new){
                return true
            }
        }
        return false
    }
    
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
    
    //MARK: Quantize - update and enable preset quanitzation functions
    func updatePresetQuantize(res: Double){
        //res is beat resolution (ex: 16 divisions of a beat)
            instruments[selectedInst].updateQuantize(res)
    }
    
    func enablePresetQuantize(){
        instruments[selectedInst].enableQuantize()
    }
    
    func disablePresetQuantize(){
        instruments[selectedInst].disableQuantize()
    }
    
    
    //MARK: Pan - update preset pan (-1 left, 0 center, 1 right and everything else in between)
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
    
    //MARK: Volume - update preset volume (percent 0 - 100%)
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
    
    //removes notes from sequence track, but don't remove notes from instrument list
    func resetTracks(){
        for inst in instruments{
            inst.trackManager.resetTrack()
        }
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
            instruments[presetNumber].instrument.rawPlay(noteNumber: note, velocity: 127)
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
        
        if !recordEnabled {
            print("Record not enabled, no add note allowed")
            playNote(instNumber)
            return
        }
        let velocity = 127
        instruments[instNumber].addNote(velocity, duration: 0) //duration is just how long to hold the beat for if not a pre recorded sample ... I think
        //if !playing { play() }
        playNote(instNumber)
        
    }
    
    func record(){
        print("Recording note")
        recordEnabled = true
        for inst in instruments{
            inst.recording = true
        }
    }
    
    
    func stop_record(){
        recordEnabled = false
        for inst in instruments{
            inst.recording = false
            inst.deselect()
        }
    }
    
    func play(){
        print("Playing notes in sequence track")
        for inst in instruments{
            inst.instrument.reset()
            inst.trackManager.updateNotePositions() //reset aksequence track and set first note, if any
        }
        /*
        if(!clickTrack.track.isPlaying){
            clickTrack.track.enableLooping()
            clickTrack.track.play()
        }
         */
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
        clickTrack.track.stop()
        clickTrack.track.disableLooping()
        playing = false
    }
    
    
    func updateTrackTempo(){
        //tell trackManager to update bpm and length based on measure and clickTrack object data
        clickTrack.update() //updates tempo only right now
    }
    
    
    func updateTrackTimeSignature(){
        //tell trackManager to update length based on time signature defined by measure and clickTrack object data
        for inst in instruments{
            inst.trackManager.updateLength()
        }
    }
    
    
}





