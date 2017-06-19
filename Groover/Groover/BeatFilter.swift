//
//  beatFilter.swift
//  Groover
//
//  Created by Joshua Thompson on 12/6/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation
import UIKit

let min_g: Int16 = 40 //increase to make less sensitive
let max_g: Int16 = 60 //increase to make less sensitive
let max_samples: Int = 10
let min_g_sum: Int16 = 235 //decrease to make more sensitive or increase for less sensitive

//Sensitivity dictionary based on iPhone model
struct SensitivityDictionaryType {
    var min_g: Int16 = 40
    var max_g: Int16 = 60
    var max_samples: Int = 10
    var min_g_sum: Int16 = 235
    
    init(min_g: Int16 = 40, max_g: Int16 = 60, samples: Int = 10, sum: Int16 = 235){
        self.min_g = min_g
        self.max_g = max_g
        self.max_samples = samples
        self.min_g_sum = sum
    }
}

let iphone_se_config = SensitivityDictionaryType(min_g: 50, max_g: 60, samples: 20, sum: (2*50 + 60))
let iphone_6and7_config = SensitivityDictionaryType(min_g: 20, max_g: 20, samples: 20, sum: (2*20 + 20))
let iphone_6and7plus_config = SensitivityDictionaryType(min_g: 15, max_g: 20, samples: 20, sum: (2*15 + 20))
let iphone_default_config = SensitivityDictionaryType(min_g: 30, max_g: 40, samples: 20, sum: (2*30 + 40))

let DeviceSensitivityConfig = [
    "iPhone SE": iphone_se_config,
    "iPhone 6and7 Plus": iphone_6and7plus_config,
    "iPhone 6and7": iphone_6and7_config,
    "default": iphone_default_config
]

enum BeatFilterTypes {
    case rising
    case falling
}

class BeatFilter {
    //Properties
    var filter_type: BeatFilterTypes!
    var config = SensitivityDictionaryType()
    var min_rise: Int16!
    var min_fall: Int16!
    var min_sum: Int16!
    var max_samples: Int!
    
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
    func updateSensitivity(){
        let modelNameShort = UIDevice.current.modelNameShort
        if(DeviceSensitivityConfig[modelNameShort] == nil){
            self.config = DeviceSensitivityConfig["default"]!
            print("beat filter default sensitivity")
        }
        else{
            self.config = DeviceSensitivityConfig[modelNameShort]!
            print("beat filter \(modelNameShort) sensitivity")
        }
        
        if(filter_type == BeatFilterTypes.rising){
             min_rise = config.max_g //100 * Gs
             min_fall = -(config.min_g) //100 * Gs
             min_sum = config.min_g_sum //100 * Gs
             max_samples = config.max_samples
        }
        else{
             min_rise = config.min_g //100 * Gs
             min_fall = -(config.max_g) //100 * Gs
             min_sum = config.min_g_sum //100 * Gs
             max_samples = config.max_samples
        }
    }
    
}

class RisingBeatFilter: BeatFilter {
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
        filter_type = BeatFilterTypes.rising
        self.updateSensitivity()
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
        }
        else if(rising){
            self.sum += diff
            samples += 1
        }
        
        var beat: Bool = (self.is_rising && self.is_falling) && (self.sum >= self.min_sum) && (self.samples <= self.max_samples)
        
        if((self.samples > max_samples) || beat){
            if(beat){
                let temp_max_sample = sample_values.max() //rising requires max (most positive number)
                if(max_sample_value != nil && temp_max_sample != nil){
                    if(Double(temp_max_sample!) < max_sample_scale*(Double(max_sample_value))){
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
        filter_type = BeatFilterTypes.falling
        self.updateSensitivity()
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
        }
            
        else if(falling){
            self.sample_values.append(x)
            self.sum += abs(diff) //abs value of falling difference
            samples += 1
        }
        
        
        var beat: Bool = (self.is_rising && self.is_falling) && (self.sum >= self.min_sum) && (self.samples <= self.max_samples)
        
        if((self.samples > max_samples) || beat){
            if(beat){
                let temp_max_sample = sample_values.min() //falling requires minimum (most negative number)
                if(max_sample_value != nil && temp_max_sample != nil){
                    if(Double(temp_max_sample!) > max_sample_scale*(Double(max_sample_value))){
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
