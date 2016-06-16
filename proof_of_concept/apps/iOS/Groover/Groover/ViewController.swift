//
//  ViewController.swift
//  Groover
//
//  Created by Alex Crane on 6/8/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
        optionsControl.addTarget(self, action: #selector(ViewController.optionButtonSelected(_:)), forControlEvents: .ValueChanged)
        soundsControl.addTarget(self, action: #selector(ViewController.soundButtonSelected(_:)), forControlEvents: .ValueChanged)
        playRecord.addTarget(self, action: #selector(ViewController.playRecordButtonSelected(_:)), forControlEvents: .ValueChanged)
        
        //set knob divider for instrument selection
        knob.setDivider(23)
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
    }
    
    //MARK: play button event handler
    func playRecordButtonSelected(playRecordButton: PlayRecordControl){
        print("play or record button changed to \(playRecordButton.currentButtonNum)")
        
    }


}

