//
//  ViewController.swift
//  Groover
//
//  Created by Alex Crane on 7/3/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //MARK: properties
    let sensor = MidiSensorWrapper()
    
    //MARK: outlets
    
    @IBOutlet weak var hamburgerButton: HamburgerIcon!
    @IBOutlet weak var popup: Popup!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Connect view controller functions to buttons events
        hamburgerButton.addTarget(self, action: #selector(ViewController.hamburgerButtonSelected(_:)), forControlEvents: .ValueChanged)
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


}

