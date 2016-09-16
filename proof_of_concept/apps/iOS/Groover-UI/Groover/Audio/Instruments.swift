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
    func quantizedBeat(beat: AKDuration)->AKDuration{
        let beats = beat.beats
        let divPos = beats * divPerBeat //position in beat divisions (based on quantized number / resolution set by user in UI: ex: 4 or 32)
        let divPosQuantized = round(divPos) //round to nearest division
        let beatsQuantized = divPosQuantized / divPerBeat //get beat position quantized
        
        let posQuantized = AKDuration(beats: beatsQuantized, tempo: beat.tempo)
        return posQuantized
        
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
    var beatOffset: Double = 0
    
    //looping
    var pos: Double = 0
    var real_pos: Double = 0
    var note_num: Int = 0
    var loop_count: Int = 0
    var _total_dur: Double = 0
    var measureUpdateReady = false

    var total_dur: Double {
        if(!measureUpdateReady){
            _total_dur = instTrack.trackManager.measureCount * instTrack.trackManager.beatsPerMeasure
        return _total_dur
        }
        else{
            return _total_dur
        }
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
        beatOffset = 0
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
            if(measureUpdateReady){
                measureUpdateReady = false //now it's ok to update measure count in looping
            }
        }
        print("note_num set to \(note_num)")
        pos = instTrack.trackManager.trackNotes[note_num].beats
        real_pos = (loop_count * total_dur) + pos
        
        print("pos \(pos) and real_pos \(real_pos)")
        let tempo = instTrack.trackManager.trackNotes[note_num].tempo
        currentNote = AKDuration(beats: real_pos + beatOffset, tempo: tempo)
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
    override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        if(beat == 0){
            loop_count += 1
        }
        beat+=1
        pos += 1
        var vel = 100
        if(pos % 4 == 0){
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
    
    func record(){
        recording = true
    }
    
    func updateMeasureCount(count: Int){
        trackManager.updateMeasureCount(count)
        instrument.measureUpdateReady = true //tells instrument to update measure count in looping after next loop is ready, but not during current loop
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
    
    func insertNote(velocity: Int, position: AKDuration, duration: Double){
        var pos = position
        let note = instrument.note
        if(quantizeEnable){
            print("quantizing pos \(pos.beats)")
            pos = quantizer.quantizedBeat(pos)
            print("...to new pos \(pos.beats)")
            
        }
        print("insert track note at \(position.seconds)")
        track.tracks[trackNum].add(noteNumber: note, velocity: velocity, position: pos, duration: AKDuration(seconds: duration))
    }
    
    func addNote(velocity: Int, duration: Double){
        let elapsed = timeElapsed
        let position = AKDuration(seconds: elapsed, tempo: clickTrack.tempo.beatsPerMin)
        let absElapsed = timeElapsedAbs
        let absPosition = AKDuration(seconds: absElapsed, tempo: clickTrack.tempo.beatsPerMin)
        if(!firstInstance){
            //use relative position
            print("adding note to track at \(elapsed)")
            addNoteToList(velocity, position: position, duration: duration)
        }
        else if(firstInstance){
            //use absolute position
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
            updateNotePositions(true)
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
    
    func updateNotePositions(newRecord: Bool = false){
        if(trackNotes.count==0){return}
            firstInstance = false //first instance measure count update complete
            resetTrack()
                var position = trackNotes[0]
                let velocity = velNotes[0]
                let duration = durNotes[0]
                print("update track pos \(position.seconds)")
            if(newRecord){
                print("new record note")
                let beatOffset = Double((clickTrack.instrument.loop_count)*clickTrack.timeSignature.beatsPerMeasure)// + Double(measureCount*beatsPerMeasure)
                position = AKDuration(beats: position.beats + beatOffset, tempo: position.tempo)
                instrument.beatOffset = Double(beatOffset)
            }
            print("insert new note at \(position.seconds)")
            insertNote(velocity, position: position, duration: duration)
        
        
    }
    
    
    func clear(){
            longestTime = 0.0
            noteCount = 0
            trackNotes.removeAll()
            velNotes.removeAll()
            durNotes.removeAll()
            firstInstance = true
            measureCount = 1
            resetTrack()
            instrument.reset()
    }
    
}







