//
//  Sounds_Extra_Map.swift
//  Groover
//
//  Created by Joshua Thompson on 2/16/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation

/*****************Sound Map Struct****************/
struct SoundMapInfo {
    var number: Int = 0
    var name: String = "sound"
    var file_name: String = "sound_file_name"
    
    init(number: Int, name: String, file_name: String){
        self.number = number
        self.name = name
        self.file_name = file_name
    }
}

/*****************Position mapping for 'Sounds_acoustic_drumset' library******************/
let sounds_acoustic_maps = [
    "1-TCA-Kick": SoundMapInfo(number: 0, name: "TCA-Kick", file_name: "1-TCA-Kick"),
    "2-TCA-Snare": SoundMapInfo(number: 1, name: "TCA-Snare", file_name: "2-TCA-Snare"),
    "3-TCA-Hat": SoundMapInfo(number: 2, name: "TCA-Hat", file_name: "3-TCA-Hat"),
    "4-TCA-Hat-Choke": SoundMapInfo(number: 3, name: "TCA-Hat-Choke", file_name: "4-TCA-Hat-Choke"),
    "5-TCA-Crash-Hi": SoundMapInfo(number: 4, name: "TCA-Crash-Hi", file_name: "5-TCA-Crash-Hi"),
    "6-TCA-Crash-Low": SoundMapInfo(number: 5, name: "TCA-Crash-Low", file_name: "6-TCA-Crash-Low"),
    "7-TCA-Ride": SoundMapInfo(number: 6, name: "TCA-Ride", file_name: "7-TCA-Ride"),
    "8-TCA-Tom-High": SoundMapInfo(number: 7, name: "TCA-Tom-High", file_name: "8-TCA-Tom-High"),
    "9-TCA-Tom-Mid": SoundMapInfo(number: 8, name: "TCA-Tom-Mid", file_name: "9-TCA-Tom-Mid"),
    "10-TCA-Tom-Floor": SoundMapInfo(number: 9, name: "TCA-Tom-Floor", file_name: "10-TCA-Tom-Floor"),
    "11-TCA-Hat-Bell": SoundMapInfo(number: 10, name: "TCA-Hat-Bell", file_name: "11-TCA-Hat-Bell"),
    "12-TCA-Ride-Bell": SoundMapInfo(number: 11, name: "TCA-Ride-Bell", file_name: "12-TCA-Ride-Bell"),
    "13-TCA Stack": SoundMapInfo(number: 12, name: "TCA-Stack", file_name: "13-TCA Stack"),
    "14-TCA-Crash-Hi-Mallet": SoundMapInfo(number: 13, name: "TCA-Crash-Hi-Mallet", file_name: "14-TCA-Crash-Hi-Mallet")]


/*****************Position mapping for 'Sounds_electronic_drumset' library******************/

let sounds_electronic_maps = [
    "kick-1": SoundMapInfo(number: 0, name: "kick-1", file_name: "kick-1"),
    "kick-2": SoundMapInfo(number: 1, name: "kick-2", file_name: "kick-2"),
    "kick-3": SoundMapInfo(number: 2, name: "kick-3", file_name: "kick-3"),
    "kick-4": SoundMapInfo(number: 3, name: "kick-4", file_name: "kick-4"),
    "hat-1": SoundMapInfo(number: 4, name: "hat-1", file_name: "hat-1"),
    "snare-1": SoundMapInfo(number: 5, name: "snare-1", file_name: "snare-1"),
    "snare-2": SoundMapInfo(number: 6, name: "snare-2", file_name: "snare-2"),
    "snare-3": SoundMapInfo(number: 7, name: "snare-3", file_name: "snare-3"),
    "snare-4": SoundMapInfo(number: 8, name: "snare-4", file_name: "snare-4"),
    "hat-2": SoundMapInfo(number: 9, name: "hat-2", file_name: "hat-2"),
    "hat-3": SoundMapInfo(number: 10, name: "hat-3", file_name: "hat-3"),
    "hat-4": SoundMapInfo(number: 11, name: "hat-4", file_name: "hat-4")]



/***************** PUT CUSTOM SOUND MAP HERE ************************/
/* EXAMPLE:
 * let my_sounds_map = "sound-1": SoundMapInfo(number: 0, name: "hat sound", file_name: "sound-1"),
                       "sound-2": SoundMapInfo(number: 1, name: "snare sound", file_name: "sound-2"),
                       "sound-3": SoundMapInfo(number: 2, name: "kick sound", file_name: "sound-3")
                        ]
 
 * so sound-1 is at knob position 0 and has instrument name "hat sound" 
   and sound-2 at knob position 1 and has instrument name "snare sound" ... and so on
 * If you want sound-1 to be at knob position 2 then change 0 to 2 and make sound-3 have position 0
 */

/*******************Collection of position mappings for different sound libraries ****************/

let SoundMapCollection = ["Sounds_acoustic_drumset": sounds_acoustic_maps, "Sounds_electronic_drumset": sounds_electronic_maps]

    /* put your library map here*/
    /* ex:
     * let SoundMapCollection = ["Sounds_Extra": sounds_extra_maps, "Sounds": sounds_maps, "MySounds": custom_sound_map]
     */

/******************Default Sound Library used by InstrumentLibrary.swift **************/
let DefaultSoundsLibrary = "Sounds_acoustic_drumset" //"Sounds_electronic_drumset"
