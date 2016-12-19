//
//  ParametersModalViewController.swift
//  Groover
//
//  Created by Alex Crane on 12/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class ParametersModalViewController: UIViewController {
    
    //MARK: Properties
    //MARK: Properties
    var song: Song!
    
    
    //Measures
    @IBAction func trackMeasuresSliderValueChanged(_ sender: TrackMeasuresSliderCtrl) {
        let new_measures = trackMeasuresSlider.measures
        trackMeasuresSliderValueLabel.text = "\(new_measures)"
        self.song.updatePresetMeasureCount(new_measures)
        print("updated track measures to \(new_measures)")
    }
    @IBOutlet weak var trackMeasuresSlider: TrackMeasuresSliderCtrl!
    
    @IBOutlet weak var trackMeasuresSliderValueLabel: UITextField!
    
    //Pan
    @IBAction func panSliderValueChanged(_ sender: PanSliderCtrl) {
        let new_pan = panSlider.pan
        self.song.updatePresetPan(new_pan) // -1 to +1
        print("Pan updated to \(new_pan)")
    }
    
    @IBOutlet weak var panSlider: PanSliderCtrl!
    
    //Volume
    @IBAction func volumeSliderValueChanged(_ sender: VolumeSliderCtrl) {
        let new_volume = volumeSlider.volume
        self.song.updatePresetVolume(Double(new_volume))
        print("updated volume to \(new_volume)")
        
    }
    @IBOutlet weak var volumeSlider: VolumeSliderCtrl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.song = GlobalAttributes.song

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
