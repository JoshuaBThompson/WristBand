//
//  beatFilter.swift
//  Groover
//
//  Created by Joshua Thompson on 12/6/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation

class RisingBeatFilter {
    
    //Constants
    let min_rise: Int16 = 55 //100 * Gs
    let min_fall: Int16 = -24 //100 * Gs
    let min_sum: Int16 = 150 //100 * Gs
    let max_samples = 15
    
    //Variables
    var prev_x: Int16!
    var diff: Int16 = 0
    var sum: Int16 = 0
    var _rising: Bool = false
    var _falling: Bool = false
    var samples = 0
    
    //Computed Variables
    var is_rising: Bool {
        _rising = (_rising || (diff >= min_rise))
        return _rising
    }
    
    var is_falling: Bool {
        _falling = (_falling || (diff <= min_fall)) && _rising //only falling if prev rising
        return _falling
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
        
        
        let beat: Bool = (self.is_rising && self.is_falling) && (self.sum >= self.min_sum) && (self.samples <= self.max_samples)
        
        if((self.samples > max_samples) || beat){
            //print("beat at sample \(samples) with sum \(self.sum)")
            self.reset_capture()
        }
        
        return beat
    }
    
    func reset_capture(){
        self.samples = 0
        self._rising = false
        self._falling = false
        self.sum = 0
        self.diff = 0
    }
    
}




class FallingBeatFilter {
    
    //Constants
    let min_rise: Int16 = 24 //100 * Gs
    let min_fall: Int16 = -55 //100 * Gs
    let min_sum: Int16 = 150 //100 * Gs
    let max_samples = 15
    
    //Variables
    var prev_x: Int16!
    var diff: Int16 = 0
    var sum: Int16 = 0
    var _rising: Bool = false
    var _falling: Bool = false
    var samples = 0
    
    //Computed Variables
    var is_rising: Bool {
        _rising = (_rising || (diff >= min_rise)) && _falling //only falling if prev falling
        return _rising
    }
    
    var is_falling: Bool {
        _falling = (_falling || (diff <= min_fall))
        return _falling
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
            self.sum += diff
            samples += 1
            //print("rising sum \(self.sum) sample \(self.samples) diff \(diff)")
        }
            
        else if(falling){
            self.sum += abs(diff) //abs value of falling difference
            samples += 1
            //print("falling sum \(self.sum) sample \(self.samples) diff \(diff)")
        }
        
        
        let beat: Bool = (self.is_rising && self.is_falling) && (self.sum >= self.min_sum) && (self.samples <= self.max_samples)
        
        if((self.samples > max_samples) || beat){
            //print("beat at sample \(samples) with sum \(self.sum)")
            self.reset_capture()
        }
        
        return beat
    }
    
    func reset_capture(){
        self.samples = 0
        self._rising = false
        self._falling = false
        self.sum = 0
        self.diff = 0
    }
    
}
