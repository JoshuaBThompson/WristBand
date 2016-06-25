//
//  ViewController.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //MARK: properties
    var song: Song!
    var audioMidiSetupEn = true
    var manufactureName: String!
    let sensor = MidiSensorWrapper()
    let motionManager = CMMotionManager()
    let queue = NSOperationQueue.mainQueue()
    var timeIntervalMillis: UInt = 25
    var eventCount = 0
    
    //MARK: outlets
    @IBOutlet weak var optionsControl: OptionsControl!
    @IBOutlet weak var knob: Knob!
    @IBOutlet weak var soundsControl: SoundsControl!
    
    @IBOutlet weak var playRecord: PlayRecordControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //https://developer.apple.com/library/ios/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson3.html
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), forControlEvents: .ValueChanged)
        knob.addTarget(self, action: #selector(ViewController.innerKnobTapped(_:)), forControlEvents: .EditingChanged)
        optionsControl.addTarget(self, action: #selector(ViewController.optionButtonSelected(_:)), forControlEvents: .ValueChanged)
        soundsControl.addTarget(self, action: #selector(ViewController.soundButtonSelected(_:)), forControlEvents: .ValueChanged)
        playRecord.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), forControlEvents: .ValueChanged)
        
        //set knob divider for instrument selection
        knob.setDivider(23)
        
        //Midi
        // Do any additional setup after loading the view, typically from a nib.
        //debugLabel.text = "View did load"
        song = Song()
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = NSTimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler: beatHandler)
            
        }
        
        //hide keyboard
        //self.tempoTextField.delegate = self;
        //self.timeSigTextFieldBPM.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: knob event handlers
    func knobAngleChanged(knobControl: Knob){
        print("knob angle changed to \(knobControl.angle)!")
        print("knob detentNum \(knob.detentNum)")
        optionsControl.selectButtonByNum(knob.detentNum)
        let instrumentNum = optionsControl.currentOptionNum //ex: 0 or 1 or 2 or 3
        song.selectInstrument(instrumentNum)
        updateButtonStatesAfterKnobTurn()
        
    }
    
    func innerKnobTapped(knobControl: Knob){
        print("Inner knob tapped")
        song.toggleTempo()
        
        //temporary hack when not using iPhone (using simulator) to allow for beat generation 
        song.addSelectedNote() //Used for testing in sim mode to simulate motion generated beat
        updateButtonStatesAfterNoteAdded()
    }
    
    //MARK: Option button event handlers
    func optionButtonSelected(optionButton: OptionsControl){
        print("option control button changed")
        print("option button changed to \(optionButton.currentOptionNum)")
    }
    
    //MARK: Sound preset button event handlers
    func soundButtonSelected(soundButton: SoundsControl){
        print("sound control button changed")
        print("sound control button changed ot \(soundButton.currentSoundNum)")
        song.selectedPreset = soundsControl.currentSoundNum
    }
    
    //MARK: play button event handler
    func playRecordButtonSelected(playRecordButton: PlayRecordControl){
        print("play or record button changed to \(playRecordButton.currentButtonNum)")
        switch playRecordButton.currentButtonType {
        case .PLAY:
            if(playRecordButton.playButton.on){
                song.stop() //disable recording first
                song.play()
            }
            else{
                song.stop()
            }
            
        case .CLEAR:
            //clear track
            if(song.recordEnabled){
                print("clear current instrument song")
                song.instrument.clear()
            }
            
        case .RECORD:
            //record if on
            if(playRecordButton.recordButton.on){
                song.record()
                print("start record and enable clear")
            }
            else{
                song.stop()
                print("stop record and disable clear")
            }
            
        }
        
    }
    
    //MARK: Midi Sensor and AudioKit methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    //MARK: update button states after note added
    func updateButtonStatesAfterNoteAdded(){
        //note added so check if recording
        //if recording then make the clear button visible again 
        //to give user chance to clear track again
        print("update after note called")
        if(song.recordEnabled && !playRecord.clearButton.active){
            print("update after note added")
            playRecord.manualSelectButton(.CLEAR)
        }
    }
    
    func updateButtonStatesAfterKnobTurn(){
        //knob turned so check if recording
        //if recording then make the clear button visible again only if turned to diff instrument
        //to give user chance to clear track again
        print("update after knob turned called")
        if(song.recordEnabled && !playRecord.clearButton.active && song.selectedInstrument != song.prevSelectedInstrument && song.instrument.empty){
            print("update after knob turned added")
            playRecord.manualSelectButton(.CLEAR)
        }
    }
    
    
    //MARK: Motion Sensor Functions
    func beatHandler(data: CMAccelerometerData?, error: NSError?){
        let valx = Int32(16383.0 * (data!.acceleration.x))
        let valy = Int32(16383.0 * (data!.acceleration.y))
        let valz = Int32(16383.0 * (data!.acceleration.z))
        
        sensor.updateStateWith(valx, andY: valy, andZ: valz, andMillisElapsed: timeIntervalMillis);
        sensor.handleMidiEvents();
        if(sensor.beat){
            //let eventNote = Int(sensor.getEventNote())
            let eventStatus = Int(sensor.getEventStatus())
            if eventStatus != 0x80{
                song.addSelectedNote() //make drum sound and add to track if recording!
                eventCount = eventCount + 1
                updateButtonStatesAfterNoteAdded()
            }
            
        }
        
    }


}

