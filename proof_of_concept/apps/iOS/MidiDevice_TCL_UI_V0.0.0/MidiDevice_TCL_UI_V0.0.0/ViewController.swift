//
//  ViewController.swift
//  MidiDevice_TCL_UI_V0.0.0
//
//  Created by Joshua Thompson on 6/1/16.
//  Copyright © 2016 Joshua Thompson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //let rangeSlider = RangeSlider(frame: CGRectZero)
    var knobAngle: CGFloat = 281
    
    //MARK: outlets
    /*
    @IBOutlet weak var knobImage: Knob!
    
    //MARK: actions
    
    @IBAction func turnKnobButton(sender: UIButton) {
        knobAngle = knobAngle + 10
        knobImage.turnKnob(knobAngle: knobAngle, innerKnobAngle: 0)
    }
 */

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //rangeSlider.backgroundColor = UIColor.redColor()
        //view.addSubview(rangeSlider)
    }

    override func viewDidLayoutSubviews() {
        //let margin: CGFloat = 20.0
        //let width = view.bounds.width - 2.0 * margin
        //rangeSlider.frame = CGRect(x: margin, y: margin + topLayoutGuide.length, width: width, height: 31.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
