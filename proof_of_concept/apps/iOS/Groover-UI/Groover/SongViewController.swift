//
//  SongViewController.swift
//  Groover
//
//  Created by Alex Crane on 12/5/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class SongViewController: UIViewController {
    //MARK: Properties
    var song: Song!
    
    //MARK: UI Element Controls
    
    //MARK: tempo

    @IBAction func tempoSliderValueChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        tempoSliderLabel.text = "\(value)"
        self.song.setTempo(Double(value))
        
    }
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var tempoSliderLabel: UITextField!
   
    
    
    //MARK: Time Signature

    
    @IBAction func timeSignatureValueChanged(_ sender: UISlider) {
        let value = sender.value
        print("Time Signature \(value)")
    }
    
    @IBOutlet weak var timeSignatureSlider: UISlider!
    @IBOutlet weak var timeSigBeatsLabel: UITextField!
    @IBOutlet weak var timeSigDivisionsLabel: UITextField!
    
    //MARK: Measure
    @IBAction func measureSliderValueChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        measureSliderLabel.text = "\(value)"
        self.song.updatePresetMeasureCount(value)
    }
    @IBOutlet weak var measureSlider: UISlider!
    @IBOutlet weak var measureSliderLabel: UITextField!
    
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.song = GlobalAttributes.song
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        

        self.navigationItem.title = "Long Ass Song Title Placeholder"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func unwindToSong(segue: UIStoryboardSegue) {}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
