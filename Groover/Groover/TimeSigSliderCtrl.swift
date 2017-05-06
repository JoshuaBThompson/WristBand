//
//  TimeSigSliderCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 12/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

class TimeSigSliderCtrl: SliderCtrl{
    var time_sig_gen = TimeSigLabelGen()
    var default_time_sig = TimeSigStruct()
    var default_beat: Int = 4
    var default_division: Int = 4
    var default_detent: Int = 0
    
    func init_vars(){
        self.default_time_sig.beat = self.default_beat
        self.default_time_sig.division = self.default_division
        self.default_detent = self.time_sig_gen.get_detent(time_sig: self.default_time_sig)
        self.max_value = 100
        self.min_value = 0
        self.default_value = 0
        self.maxPosX = 190.0
        self.minPosX = 5.0
        let max_detent_count = self.time_sig_gen.max_beats * self.time_sig_gen.max_divisions
        self.snapFilter = SliderSnapFilter(detentCount: max_detent_count, posOffset: self.minPosX, posRange: self.maxPosX)
        self.snapFilter.scale = 1.0 /* tempo is updated by 5 pbm at a time using the slider */
        self.snapFilter.scale_offset = 0.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        init_vars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init_vars()
    }
    
    
    //MARK: Draw
    override func draw(_ rect: CGRect) {
        if(self.position == nil){
            self.position = CGPoint(x: 0, y: 0)
            
            self.update_pos_from_detent(new_detent: self.default_detent)
            
            self.time_sig_gen.update_current_time_sig(detent: Int(scaled_detent))
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            
        }
            
        else{
            self.time_sig_gen.update_current_time_sig(detent: Int(scaled_detent))
            UIGroover.drawSliderCanvas(sliderPosition: self.position.x)
            print("time sig is \(time_sig_gen.current_time_sig.beat) / \(time_sig_gen.current_time_sig.division)")
        }
    }
}

/* Generate the top and bottom values of time signature */
struct TimeSigStruct {
    var beat = 1
    var division = 1
}

class TimeSigLabelGen {
    
    //MARK: Properties
    var beats = [Int]()
    var divisions = [Int]()
    var time_sigs = [TimeSigStruct]()
    let max_divisions = 3
    let max_beats = 13
    var current_time_sig = TimeSigStruct()
    
    func init_beats_array(){
        /*
         1,2,3,4,5,6,7,8,9,10,12,13
        */
        for i in 1 ... max_beats {
            beats.append(i)
        }
    }
    
    func init_divisions_array(){
        /*
         2/2, 4/4, 8/8
        */
        divisions.append(2)
        divisions.append(4)
        divisions.append(8)
    }
    
    func init_time_sigs(){
        for div in 0 ..< max_divisions {
            for beat in 0 ..< max_beats {
                var new_time_sig = TimeSigStruct()
                new_time_sig.beat = beats[beat]
                new_time_sig.division = divisions[div]
                time_sigs.append(new_time_sig)
            }
        }
    }
    
    func get_time_sig(detent: Int)->TimeSigStruct{
        if(detent >= time_sigs.count){
            let c = time_sigs.count-1
            let time_sig = time_sigs[c]
            return time_sig
        }
        else if(detent < 0){
            let time_sig = time_sigs[0]
            return time_sig
        }
        let time_sig = time_sigs[detent]
        return time_sig
    }
    
    func get_detent(time_sig: TimeSigStruct)->Int{
        var detent = 0
        for i in 0 ..< self.time_sigs.count {
            if (time_sig.beat == self.time_sigs[i].beat){
                if(time_sig.division == self.time_sigs[i].division){
                    detent = i
                    return detent
                }
            }
        }
        
        return detent
    }
    
    func update_current_time_sig(detent: Int){
        current_time_sig = get_time_sig(detent: detent)
    }
    
    func get_divisions_num(detent: Int)->Int{
        return 0
    }
    
    //MARK: Init
    init(){
        init_beats_array()
        init_divisions_array()
        init_time_sigs()
    }
}
