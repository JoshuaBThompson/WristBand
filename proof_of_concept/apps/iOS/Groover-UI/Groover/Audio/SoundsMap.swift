//
//  Sounds_Extra_Map.swift
//  Groover
//
//  Created by Joshua Thompson on 2/16/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation

/*****************Position mapping for 'Sounds_Extra' library******************/

let sounds_extra_maps = ["hat-1": 0,
"hat-2": 1,
"hat-3": 2,
"hat-4": 3,
"kick-1": 4,
"kick-2": 5,
"kick-3": 6,
"kick-4": 7,
"snare-1": 8,
"snare-2": 9,
"snare-3": 10,
"snare-4": 11]

/*****************Position mapping for 'Sounds' library******************/
let sounds_maps = ["hat-1": 0,
"hat-2": 1,
"hat-3": 2,
"hat-4": 3,
"kick-1": 4,
"kick-2": 5,
"kick-3": 6,
"kick-4": 7,
"snare-1": 8,
"snare-2": 9,
"snare-3": 10,
"snare-4": 11]

/*****************Put your custom sound map here ************************/
/* ex:
 * let my_sounds_map = ["sound-1": 0, "sound-2": 1, "sound-3":2]
 * so sound-1 is at knob position 0 and sound-2 at knob position 1 and so on
 * If you want sound-1 to be at knob position 2 then change 0 to 2 and make sound-3 have position 0
 */

/*******************Collection of position mappings for different sound libraries ****************/

let SoundMapCollection = ["Sounds_Extra": sounds_extra_maps, "Sounds": sounds_maps]
    /* put your library map here*/
    /* ex:
     * let SoundMapCollection = ["Sounds_Extra": sounds_extra_maps, "Sounds": sounds_maps, "MySounds": custom_sound_map]
     */

/******************Default Sound Library used by InstrumentLibrary.swift **************/
let DefaultSoundsLibrary = "Sounds" //"Sounds_Extra"
