//
//  beatFilter.swift
//  Groover
//
//  Created by Joshua Thompson on 12/6/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation

let min_g: Int16 = 40 //increase to make less sensitive
let max_g: Int16 = 60 //increase to make less sensitive
let max_count = 10
let min_g_sum: Int16 = 235 //decrease to make more sensitive or increase for less sensitive

class BeatFilter {
    //Constants
    var min_rise: Int16 = 55 //100 * Gs
    var min_fall: Int16 = -24 //100 * Gs
    var min_sum: Int16 = 150 //100 * Gs
    var max_samples = 15
    
    //Variables
    var prev_x: Int16!
    var diff: Int16 = 0
    var sum: Int16 = 0
    var _rising: Bool = false
    var _falling: Bool = false
    var samples = 0
    var sample_values = [Int16]()
    var max_sample_value: Int16!
    var max_sample_scale: Double = 0.65
    
    init() {
    }
    
    func reset_capture(){
        self.samples = 0
        self._rising = false
        self._falling = false
        self.sum = 0
        self.diff = 0
        self.sample_values = [Int16]()
    }
    
}

class RisingBeatFilter: BeatFilter {
    
    //Constants
    
    //Variables
    
    //Computed Variables
    var is_rising: Bool {
        _rising = (_rising || (diff >= min_rise))
        return _rising
    }
    
    var is_falling: Bool {
        _falling = (_falling || (diff <= min_fall)) && _rising //only falling if prev rising
        return _falling
    }
    
    override init() {
        super.init()
        min_rise = max_g //100 * Gs
        min_fall = -(min_g) //100 * Gs
        min_sum = min_g_sum //100 * Gs
        max_samples = max_count

    }
    
    
    //Functions
    func isBeat(x: Int16)->Bool{
        
        //only start when at least two samples have been measured
        if(self.prev_x == nil){
            self.prev_x = x
            return false
        }
        
        
        self.diff = x - self.prev_x
        self.prev_x = x
        let rising = self.is_rising
        let falling = self.is_falling
        
        if(falling){
            self.sum += abs(diff) //abs value of falling difference
            samples += 1
            //print("falling sum \(self.sum) sample \(self.samples) diff \(diff)")
        }
        else if(rising){
            self.sum += diff
            samples += 1
            //print("rising sum \(self.sum) sample \(self.samples) diff \(diff)")
        }
        
        
        var beat: Bool = (self.is_rising && self.is_falling) && (self.sum >= self.min_sum) && (self.samples <= self.max_samples)
        
        if((self.samples > max_samples) || beat){
            //print("beat at sample \(samples) with sum \(self.sum)")
            if(beat){
                let temp_max_sample = sample_values.max() //rising requires max (most positive number)
                print("max_sample \(max_sample_value)")
                print("temp_max \(String(describing: temp_max_sample))")
                if(max_sample_value != nil && temp_max_sample != nil){
                    if(Double(temp_max_sample!) < max_sample_scale*(Double(max_sample_value))){
                        print("beat canceled")
                        beat = false
                    }
                }
                max_sample_value = temp_max_sample
            }
            
            if(!beat){
                max_sample_value = nil
            }
            self.reset_capture()
        }
        
        return beat
    }
    
    
}




class FallingBeatFilter: BeatFilter {
    
    //Constants
    
    //Variables
    
    //Computed Variables
    var is_rising: Bool {
        _rising = (_rising || (diff >= min_rise)) && _falling //only rising if prev falling
        return _rising
    }
    
    var is_falling: Bool {
        _falling = (_falling || (diff <= min_fall))
        return _falling
    }
    
    override init(){
        super.init()
        min_rise = min_g //100 * Gs
        min_fall = -(max_g) //100 * Gs
        min_sum = min_g_sum //100 * Gs
        max_samples = max_count
        
    }
    
    //Functions
    func isBeat(x: Int16)->Bool{
        
        //only start when at least two samples have been measured
        if(self.prev_x == nil){
            self.prev_x = x
            return false
        }
        
        
        self.diff = x - self.prev_x
        self.prev_x = x
        let falling = self.is_falling
        let rising = self.is_rising
        
        if(rising){
            self.sample_values.append(x)
            self.sum += diff
            samples += 1
            //print("rising sum \(self.sum) sample \(self.samples) diff \(diff)")
        }
            
        else if(falling){
            self.sample_values.append(x)
            self.sum += abs(diff) //abs value of falling difference
            samples += 1
            //print("falling sum \(self.sum) sample \(self.samples) diff \(diff)")
        }
        
        
        var beat: Bool = (self.is_rising && self.is_falling) && (self.sum >= self.min_sum) && (self.samples <= self.max_samples)
        
        if((self.samples > max_samples) || beat){
            //print("beat at sample \(samples) with sum \(self.sum)")
            if(beat){
                let temp_max_sample = sample_values.min() //falling requires minimum (most negative number)
                print("max_sample \(max_sample_value)")
                print("temp_max \(String(describing: temp_max_sample))")
                if(max_sample_value != nil && temp_max_sample != nil){
                    if(Double(temp_max_sample!) > max_sample_scale*(Double(max_sample_value))){
                        beat = false
                        print("beat canceled")
                    }
                }
                max_sample_value = temp_max_sample
            }
            
            if(!beat){
                max_sample_value = nil
            }
            self.reset_capture()
        }
        
        return beat
    }
    
    
}
