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
    var saved_song_name: String!
    var cancelled = false
    //MARK: UI Element Controls
    
    //MARK: tempo
    @IBAction func tempoSliderValueChanged(_ sender: TempoSliderCtrl) {
        let value = Int(sender.tempo)
        tempoSliderTextField.text = "\(value)"
        if(tempoSlider.ready){
            self.updateTempo(value: Double(value))
        }
    }
    
    @IBOutlet weak var tempoSlider: TempoSliderCtrl!
    @IBOutlet weak var tempoSliderTextField: UITextField!
    
    
    //MARK: Time Signature

    
    @IBAction func timeSignatureValueChanged(_ sender: TimeSigSliderCtrl) {
        timeSigBeatsTextField.text = "\(sender.time_sig_gen.current_time_sig.beat)"
        timeSigDivisionsTextField.text = "\(sender.time_sig_gen.current_time_sig.division)"
        if(timeSignatureSlider.ready){
            song.setTimeSignature(sender.time_sig_gen.current_time_sig.beat, beatUnit: sender.time_sig_gen.current_time_sig.division)
        }
        
    }
    
    @IBOutlet weak var timeSignatureSlider: TimeSigSliderCtrl!
    @IBOutlet weak var timeSigBeatsTextField: UITextField!
    @IBOutlet weak var timeSigDivisionsTextField: UITextField!
    
    //MARK: Measure
    
    @IBAction func measureSliderValueChanged(_ sender: GlobalMeasuresCtrl) {
        let value = Int(sender.measures)
        measuresSliderTextField.text = "\(value)"
        /* update global measure count ? */
        
        if(measureSlider.ready){
            self.song.setDefaultMeasures(measureCount: value)
        }
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
        GlobalAttributes.songViewController = self
        GlobalAttributes.songSelected = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        
        self.navigationItem.title = self.song.current_song.name//"Long Ass Song Title Placeholder"
        
        self.initTempoSlider()
        self.initDefaultMeasuresSlider()
    }

    //MARK: Init tempo 
    func initTempoSlider(){
        let tempo = Int(self.song.tempo.beatsPerMin)
        tempoSliderTextField.text = "\(tempo)"
        tempoSlider.update_pos_from_detent(new_detent: tempo)
    }
    
    //MARK: Init global default measures
    func initDefaultMeasuresSlider(){
        let measures = self.song.defaultMeasureCount
        measuresSliderTextField.text = "\(measures)"
        measureSlider.update_pos_from_detent(new_detent: measures)
    }
    
    //MARK: Init time signature values
    func initTimeSignatureSlider(){
        let beats = self.song.timeSignature.beatsPerMeasure
        let note = self.song.timeSignature.beatUnit
        timeSigBeatsTextField.text = "\(beats)"
        timeSigDivisionsTextField.text = "\(note)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func unwindToSong(segue: UIStoryboardSegue) {
        print("unwindToSong")
    }
    
    //MARK: cancel unwind
    @IBAction func unwindCancelNewSong(segue: UIStoryboardSegue) {
        print("cancel new song")
        
    }
    
    @IBAction func unwindCancelSongSelection(segue: UIStoryboardSegue){
        print("cancel song selection")
        cancelled = true
    }
    
    //MAR: Save unwind
    @IBAction func unwindSaveNewSong(segue: UIStoryboardSegue) {
        print("save new song")
        self.saveSong()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Delete song
    func deleteSong(num: Int){
        song.deleteSong(num: num)
    }
    
    //Update Title
    func setSongName(title: String){
        self.navigationItem.title = title
    }
    
    //Load song into current song
    func setSong(song_num: Int){
        self.song.loadSong(song_num: song_num)
    }
    
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
    
    //MARK: make new song if necessary
    func loadNewSong(){
        self.song.loadNewSong()
    }
    
    //MARK: save new song name
    func updateNewSongName(name: String){
        self.song.setSongName(name: name)
    }
    
    //MARK: tell song class to mark song as to be saved in database
    func setSongAsSaved(){
        self.song.setSongSave()
    }
    
    //MARK: save song
    func saveSong(){
        let song_name = self.saved_song_name!
        let current_song_saved = self.song.isSongSaved()
        
        //if current song is not a saved song this means it was generated when the user started the app
        //so it is already a new song - we will use this song as the newly created song
        if(current_song_saved == false){
            print("saving current song as new song")
            self.setSongAsSaved() //tell song class to make current song a saved song
        }
        else{
            //if we were currently running a saved song then make a new song
            print("creating a new song!")
            self.loadNewSong()
            self.setSongAsSaved() //tell song class to make current song a saved song
        }
        
        //last but not least, update the song name with the text the user input
        print("setting song name to \(song_name)")
        self.updateNewSongName(name: song_name)
        
        //now save song to database
        self.song.saveSong()
        
        self.setSongName(title: song_name) //set title of song view to current song name
        
    }

}
