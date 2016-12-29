//
//  ParametersModalViewController.swift
//  Groover
//
//  Created by Alex Crane on 12/4/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class ParametersModalViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    var song: Song!
    
    @IBAction func deleteTrackButton(_ sender: UIButton) {
        song.clearPreset()
        print("song clear preset!")
    }
    
    //Measures
    @IBAction func trackMeasuresSliderValueChanged(_ sender: TrackMeasuresSliderCtrl) {
        let new_measures = trackMeasuresSlider.measures
        trackMeasuresSliderValueTextField.text = "\(new_measures)"
        self.song.updatePresetMeasureCount(new_measures)
        print("updated track measures to \(new_measures)")
    }
    
    @IBOutlet weak var trackMeasuresSlider: TrackMeasuresSliderCtrl!
    
    @IBOutlet weak var trackMeasuresSliderValueTextField: UITextField!
    
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
        self.trackMeasuresSliderValueTextField.delegate = self
        self.song = GlobalAttributes.song
        self.initMeasureSlider()
        self.initPanSlider()
        self.initVolumeSlider()
    }

    //MARK: Init measure slider
    func initMeasureSlider(){
        self.trackMeasuresSlider.update_pos_from_value(new_value: CGFloat(self.song.presetMeasureCount))
        let new_measures = trackMeasuresSlider.measures
        trackMeasuresSliderValueTextField.text = "\(new_measures)"
    }
    
    //MARK: Init pan slider
    func initPanSlider(){
        self.panSlider.update_pos_from_value(new_value: CGFloat(self.song.currentPanPercent))
    }
    
    //MARK: Init vol slider
    func initVolumeSlider(){
        let vol = CGFloat(self.song.presetVolumePercent)
        self.volumeSlider.update_pos_from_value(new_value: vol)
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
    
    //MARK: Update song track measure
    func updateTrackMeasure(value: Int){
        self.song.updatePresetMeasureCount(value)
    }
    
    func updateTrackMeasuresFromTextField(){
        let measure_string: String? = self.trackMeasuresSliderValueTextField.text
        if(measure_string != nil){
            let current_preset_meausure: Int =  self.song.presetMeasureCount
            print("track measures from text = \(measure_string!)")
            let preset_measures: Int? = Int(measure_string!)
            if(preset_measures != nil){
                self.updateTrackMeasure(value: preset_measures!)
            }
            else{
                self.trackMeasuresSliderValueTextField.text = "\(Int(current_preset_meausure))"
            }
        }
    }
    
    
    //MARK: UITextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called")
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("TextField should snd editing method called")
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == self.trackMeasuresSliderValueTextField){
            self.updateTrackMeasuresFromTextField()
        }
        
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }

}
