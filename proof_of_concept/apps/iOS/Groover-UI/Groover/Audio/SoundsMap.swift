//
//  Sounds_Extra_Map.swift
//  Groover
//
//  Created by Joshua Thompson on 2/16/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation

/*****************Position mapping for 'Sounds_Extra' library******************/
/*
var sound_extra_maps = [String: Int]()
sound_extra_maps["hat-1"] = 0
sound_extra_maps["hat-2"] = 1
sound_extra_maps["hat-3"] = 2
sound_extra_maps["hat-4"] = 3

sound_extra_maps["kick-1"] = 4
sound_extra_maps["kick-2"] = 5
sound_extra_maps["kick-3"] = 6
sound_extra_maps["kick-4"] = 7

sound_extra_maps["snare-1"] = 8
sound_extra_maps["snare-2"] = 9
sound_extra_maps["snare-3"] = 10
sound_extra_maps["snare-4"] = 11
 */

let sound_extra_maps = ["hat-1": 0,
"hat-2": 11,
"hat-3": 2,
"hat-4": 3,
"kick-1": 4,
"kick-2": 5,
"kick-3": 6,
"kick-4": 7,
"snare-1": 8,
"snare-2": 9,
"snare-3": 10,
"snare-4": 1]

/*******************Collection of position mappings for different sound libraries ****************/

/*
var SoundMapCollection = [String: [String: Int]]()
SoundMapCollection["Sounds_Extra"] = sound_extra_maps
*/
let SoundMapCollection = ["Sounds_Extra": sound_extra_maps]
