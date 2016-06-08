//
//  ViewController.swift
//  MidiDevice_TCL_UI_V0.0.0
//
//  Created by Joshua Thompson on 6/1/16.
//  Copyright © 2016 Joshua Thompson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: properties
    

    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://developer.apple.com/library/ios/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson3.html
        ratingControl.addTarget(self, action: #selector(ViewController.knobAngleChanged(_:)), forControlEvents: .ValueChanged)
    }

    override func viewDidLayoutSubviews() {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Functions
    func knobAngleChanged(ratingController: RatingControl) {
        
        let angle = ratingControl.knobAngle;
        print("knob angle now \(angle)")
    }


}
