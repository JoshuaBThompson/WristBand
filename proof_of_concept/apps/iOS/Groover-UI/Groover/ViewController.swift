//
//  ViewController.swift
//  Groover
//
//  Created by Alex Crane on 7/3/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //MARK: properties
    var song: Song!
    var audioMidiSetupEn = true
    let sensor = MidiSensorWrapper()
    let motionManager = CMMotionManager()
    let queue = NSOperationQueue.mainQueue()
    var timeIntervalMillis: UInt = 25
    var eventCount = 0
    
    //MARK: outlets
    
    @IBOutlet weak var hamburgerButton: HamburgerIcon!
    @IBOutlet weak var popup: Popup!
    @IBOutlet weak var positionIndicator: PositionIndicator!
    @IBOutlet weak var knob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Connect view controller functions to buttons events
        hamburgerButton.addTarget(self, action: #selector(ViewController.hamburgerButtonSelected(_:)), forControlEvents: .ValueChanged)
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), forControlEvents: .ValueChanged)
        knob.addTarget(self, action: #selector(ViewController.innerKnobTapped(_:)), forControlEvents: .EditingChanged)
        
        song = Song()
        song.start()
        
        motionManager.startAccelerometerUpdates()
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = NSTimeInterval(Double(timeIntervalMillis)/1000.0)
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler: beatHandler)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Button event handlers
    
    func hamburgerButtonSelected(button: HamburgerIcon){
        print("hamburger button selected")
        popup.toggleHide()
    }
    
    //MARK: Knob event handlers
    func knobAngleChanged(knobControl: Knob){
        print("knob angle changed to \(knobControl.angle)!")
        print("knob detentNum \(knob.detent)")
        positionIndicator.setPosition(knobControl.detent)
        let position = positionIndicator.currentPos //ex: 0 or 1 or 2 or 3...17
        selectSound(position)
        //updateButtonStatesAfterKnobTurn()
        
    }
    
    func selectSound(position: Int){
        if(position >= 0 && position <= 3){
            //inst 0
            song.selectInstrument(0)
            let preset = position - 0 //this will result in number 0 - 3
            song.selectedPreset = preset
            print("inst 0 with preset \(preset)")
        }
        else if(position >= 4 && position <= 7){
            //inst 1
            song.selectInstrument(1)
            let preset = position - 4 //this will result in number 0 - 3
            song.selectedPreset = preset
            print("inst 1 with preset \(preset)")
        }
        else if(position >= 8 && position <= 11){
            //inst 2
            song.selectInstrument(2)
            let preset = position - 8 //this will result in number 0 - 3
            song.selectedPreset = preset
            print("inst 2 with preset \(preset)")
        }
        else{
            //only have 3 inst right now, so do nothing if position > 12
            print("inst not selected")
        }
    }
    
    func innerKnobTapped(knobControl: Knob){
        print("Inner knob tapped")
        song.toggleTempo()
        
        //temporary hack when not using iPhone (using simulator) to allow for beat generation
        song.addSelectedNote() //Used for testing in sim mode to simulate motion generated beat
        //updateButtonStatesAfterNoteAdded()
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
                //updateButtonStatesAfterNoteAdded()
            }
            
        }
        
    }


}

