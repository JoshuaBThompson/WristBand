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
    @IBOutlet weak var play: Play!
    @IBOutlet weak var record: Record!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //https://developer.apple.com/library/ios/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson3.html
        knob.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), forControlEvents: .ValueChanged)
        optionsControl.addTarget(self, action: #selector(ViewController.optionButtonSelected(_:)), forControlEvents: .ValueChanged)
        soundsControl.addTarget(self, action: #selector(ViewController.soundButtonSelected(_:)), forControlEvents: .ValueChanged)
        play.addTarget(self, action: #selector(ViewController.playButtonSelected(_:)), forControlEvents: .ValueChanged)
        record.addTarget(self, action: #selector(ViewController.recordButtonSelected(_:)), forControlEvents: .ValueChanged)
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
        print("knob angle changed!")
    }
    
    //MARK: Option button event handlers
    func optionButtonSelected(optionButton: OptionsControl){
        print("option control button changed")
    }
    
    //MARK: Sound preset button event handlers
    func soundButtonSelected(soundButton: SoundsControl){
        print("sound control button changed")
    }
    
    //MARK: play button event handler
    func playButtonSelected(playButton: Play){
        print("play button changed")
    }
    
    //MARK: record button event handler
    func recordButtonSelected(recordButton: Record){
        print("record button changed")
    }

}

