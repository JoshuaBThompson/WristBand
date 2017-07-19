//
//  NewSongViewController.swift
//  Groover
//
//  Created by Alex Crane on 12/10/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class NewSongViewController: UIViewController {
    //MARK: Properties
    var saved = false
    
    
    @IBOutlet weak var newSongLabel: UILabel!
    @IBOutlet weak var newSongTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.newSongTextField?.delegate = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage =  UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    //MARK: Text Field Delegates
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
        textField.becomeFirstResponder()
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
        if(textField == self.newSongTextField){
            //self.newSongLabel.text = textField.text
        }
        
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.destination is SongViewController){
            print("about to leave new song view")
            GlobalAttributes.songViewController.saved_song_name = self.newSongTextField.text
        }
    }
    

}
