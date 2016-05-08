//
//  ViewController.swift
//  MidiDevice_TCL_V0.0.0
//
//  Created by sofiebio on 4/21/16.
//  Copyright © 2016 wristband. All rights reserved.
//

import UIKit
import AudioKit
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate {
    var song: Song!
    var audioMidiSetupEn = true
    var manufactureName: String!
    let sensor = MidiSensorWrapper()
    let motionManager = CMMotionManager()
    let queue = NSOperationQueue.mainQueue()
    var timeIntervalMillis: UInt = 25
    var eventCount = 0
    
    //MARK: outlets
    
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var measureDurationLabel: UILabel!
    
    @IBOutlet weak var measureCountTextField: UILabel!
    
    @IBOutlet weak var tempoTextField: UITextField!
    
    @IBOutlet weak var timeSigTextFieldBPM: UITextField!
    
    @IBOutlet weak var timeSigTextFieldNote: UITextField!
    
    @IBOutlet weak var instrumentLabel: UILabel!
    
    @IBOutlet weak var beatCountLabel: UILabel!
    
    //MARK: actions
    
    @IBAction func selectInstrument1(sender: UIButton) {
        let instrumentNum = 0
        instrumentLabel.text = String(format: "Inst %d", instrumentNum+1 )
        song.selectInstrument(instrumentNum)
    }
    
    @IBAction func selectInstrument2(sender: UIButton) {
        let instrumentNum = 1
        instrumentLabel.text = String(format: "Inst %d", instrumentNum+1 )
        song.selectInstrument(instrumentNum)
    }
    
    
    @IBAction func simulateBeat(sender: UIButton) {
        //simulate what would happen if user makes beat motion
        //copied from beat handler
        song.addSelectedNote() //make drum sound and add to track if recording!
        eventCount = eventCount + 1
        self.beatCountLabel.text = String(format:"%d", eventCount);
        
    }
    
    @IBAction func addNote3(sender: UIButton) {
        print("adding note preset3")
        self.song.addNote(preset: 3)
    }
    
    @IBAction func addNote2(sender: UIButton) {
        print("adding note preset2")
        self.song.addNote(preset: 2)
    }
    
    @IBAction func addNote1(sender: UIButton) {
        print("adding note preset1")
        self.song.addNote(preset: 1)
    }
    
    
    @IBAction func addNote0(sender: UIButton) {
        print("adding note preset0")
        self.song.addNote(preset: 0)
        
    }
    
    @IBAction func setNote3(sender: UIButton) {
        print("setting preset to 3")
        song.selectedPreset = 3
    }
    
    @IBAction func setNote2(sender: UIButton) {
        print("setting preset to 2")
        song.selectedPreset = 2
    }
    
    
    @IBAction func setNote1(sender: UIButton) {
        print("setting preset to 1")
        song.selectedPreset = 1
    }
    
    @IBAction func setNote0(sender: UIButton) {
        print("setting preset to 0")
        song.selectedPreset = 0
    }
    
    
    @IBAction func clear(sender: UIButton) {
        print("Clearing song")
        song.clear()
    }
    
    
    @IBAction func updateTimeSigNote(sender: UIButton) {
        print("Updating time signature beats per measure")
        let instNumber = song.selectedInstrument
        let beatsPerMeasure = song.instruments[instNumber].measure.timeSignature.beatsPerMeasure
        let note = Int(timeSigTextFieldNote.text!)!
        song.setTimeSignature(beatsPerMeasure, newNote: note)
        measureDurationLabel.text = String(format: "%f", song.instruments[instNumber].measure.totalDuration)
        measureCountTextField.text = String(format: "%d", song.instruments[instNumber].measure.count)
    }
    
    
    @IBAction func updateTimeSigBpm(sender: UIButton) {
        print("Updating time signature beats per measure")
        let instNumber = song.selectedInstrument
        let note = song.instruments[instNumber].measure.timeSignature.beatUnit
        let beatsPerMeasure = Int(timeSigTextFieldBPM.text!)!
        song.setTimeSignature(beatsPerMeasure, newNote: note)
        measureDurationLabel.text = String(format: "%f", song.instruments[instNumber].measure.totalDuration)
        measureCountTextField.text = String(format: "%d", song.instruments[instNumber].measure.count)
    }

    @IBAction func updateTempo(sender: UIButton) {
        let beatsPerMin = Double(tempoTextField.text!)!
        let instNumber = song.selectedInstrument
        song.setTempo(beatsPerMin)
        measureDurationLabel.text = String(format: "%f", song.instruments[instNumber].measure.totalDuration)
        measureCountTextField.text = String(format: "%d", song.instruments[instNumber].measure.count)
    }
    
    
    @IBAction func record(sender: UIButton) {
        song.record()
    }

    @IBAction func play(sender: UIButton) {
        song.play()
    }
    
    @IBAction func stop(sender: UIButton) {
        song.stop()
    }

    
    
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        debugLabel.text = "View did load"
        song = Song()
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = NSTimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler: beatHandler)
            
        }
        
        //hide keyboard
        self.tempoTextField.delegate = self;
        self.timeSigTextFieldBPM.delegate = self;
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.beatCountLabel.text = String(format:"%d", eventCount);
            }
            
        }
        
    }
    
    
}



