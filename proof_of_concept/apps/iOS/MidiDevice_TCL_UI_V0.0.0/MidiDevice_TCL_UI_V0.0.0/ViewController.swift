//
//  ViewController.swift
//  MidiDevice_TCL_UI_V0.0.0
//
//  Created by Joshua Thompson on 6/1/16.
//  Copyright © 2016 Joshua Thompson. All rights reserved.
//

import UIKit

//Instrument structures
enum InstrumentNumbers {case SNARE, KICK}
enum InstrumentPresets {case PRESET1, PRESET2, PRESET3, PRESET4}
struct Instrument {
    var type: InstrumentNumbers = .SNARE
    var preset: InstrumentPresets = .PRESET1
}

struct InstrumentCollection {
    var instrument: Instrument!
}

class ViewController: UIViewController {
    
    //MARK: properties
    var snare = Instrument()
    var kick = Instrument()
    var instruments = InstrumentCollection()

    @IBOutlet weak var knob: Knob!
    
    @IBOutlet weak var preset1Label: UILabel!
    
    @IBOutlet weak var preset2Label: UILabel!
    
    @IBOutlet weak var preset3Label: UILabel!
    
    @IBOutlet weak var preset4Label: UILabel!
    //MARK: actions
    
    @IBAction func selectSnare(sender: UIButton) {
        instruments.instrument = snare
    }
    
    @IBAction func selectKick(sender: UIButton) {
        instruments.instrument = kick
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snare.type = .SNARE
        kick.type = .KICK
        instruments.instrument = snare
        
        //https://developer.apple.com/library/ios/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson3.html
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), forControlEvents: .ValueChanged)
    }

    override func viewDidLayoutSubviews() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Functions
    func knobAngleChanged(knobControl: Knob) {
        
        let angle = knobControl.knobAngle;
        print("knob angle now \(angle)")
        if(angle <= 0 && angle >= -15){
            instruments.instrument.preset = .PRESET1
        }
        else if(angle < -15 && angle >= -30){
            instruments.instrument.preset = .PRESET2
        }
        else if(angle < -30 && angle >= -45){
            instruments.instrument.preset = .PRESET3
        }
        else if(angle < -45 && angle >= -90){
            instruments.instrument.preset = .PRESET4
        }
     
        
        //update color of preset labels
        preset1Label.textColor = (instruments.instrument.preset == .PRESET1) ? UIColor.redColor() : UIColor.blackColor()
        preset2Label.textColor = (instruments.instrument.preset == .PRESET2) ? UIColor.redColor() : UIColor.blackColor()
        preset3Label.textColor = (instruments.instrument.preset == .PRESET3) ? UIColor.redColor() : UIColor.blackColor()
        preset4Label.textColor = (instruments.instrument.preset == .PRESET4) ? UIColor.redColor() : UIColor.blackColor()
    }


}
