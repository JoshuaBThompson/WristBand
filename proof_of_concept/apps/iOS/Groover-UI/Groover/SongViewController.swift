//
//  SongViewController.swift
//  Groover
//
//  Created by Alex Crane on 12/5/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class SongViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    var song: Song!
    
    //MARK: UI Element Controls
    
    //MARK: tempo
    @IBAction func tempoSliderValueChanged(_ sender: TempoSliderCtrl) {
        let value = Int(sender.tempo)
        tempoSliderTextField.text = "\(value)"
        self.updateTempo(value: Double(value))
    }
    
    @IBOutlet weak var tempoSlider: TempoSliderCtrl!
    @IBOutlet weak var tempoSliderTextField: UITextField!
    
    
    //MARK: Time Signature

    
    @IBAction func timeSignatureValueChanged(_ sender: TimeSigSliderCtrl) {
        timeSigBeatsTextField.text = "\(sender.time_sig_gen.current_time_sig.beat)"
        timeSigDivisionsTextField.text = "\(sender.time_sig_gen.current_time_sig.division)"
    }
    
    @IBOutlet weak var timeSignatureSlider: TimeSigSliderCtrl!
    @IBOutlet weak var timeSigBeatsTextField: UITextField!
    @IBOutlet weak var timeSigDivisionsTextField: UITextField!
    
    //MARK: Measure
    
    @IBAction func measureSliderValueChanged(_ sender: GlobalMeasuresCtrl) {
        print("MEASURE CHANGED")
        let value = Int(sender.measures)
        measuresSliderTextField.text = "\(value)"
        /* update global measure count ? */
    }
    
    
    @IBOutlet weak var measureSlider: GlobalMeasuresCtrl!
    @IBOutlet weak var measuresSliderTextField: UITextField!
    
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.measuresSliderTextField.delegate = self
        self.timeSigBeatsTextField.delegate = self
        self.timeSigDivisionsTextField.delegate = self
        self.tempoSliderTextField.delegate = self
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
    
    //MARK: Update song tempo
    func updateTempo(value: Double){
        self.song.setTempo(value)
    }
    
    func updateTempoFromTextField(){
        let tempo_bpm: String? = self.tempoSliderTextField.text
        if(tempo_bpm != nil){
            let current_tempo_double: Double? =  self.song.tempo.beatsPerMin
            print("tempo bpm from text = \(tempo_bpm!)")
            let tempo_bpm_double: Double? = Double(tempo_bpm!)
            if(tempo_bpm_double != nil){
                self.updateTempo(value: tempo_bpm_double!)
            }
            else{
                self.tempoSliderTextField.text = "\(Int(current_tempo_double!))"
            }
        }
    }
    
    //MARK: Update time signature
    func updateTimeSignature(value: Double){
    }
    
    func updateTimeSignatureFromTextField(){
    }
    
    //MARK: Update global measures
    func updateGlobalMeasures(value: Double){
    }
    
    func updateGlobalMeasuresFromTextField(){
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
        if(textField == self.tempoSliderTextField){
            updateTempoFromTextField()
        }
        else if(textField == self.timeSigDivisionsTextField || textField == self.timeSigBeatsTextField){
            self.updateTimeSignatureFromTextField()
        }
        else if(textField == self.measuresSliderTextField){
            self.updateGlobalMeasuresFromTextField()
        }
        
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }

}
