//
//  GlobalAttributes.swift
//  Groover
//
//  Created by Joshua Thompson on 12/13/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation

class GlobalAttributes {
    static let song = Song()
    static var songViewController: SongViewController!
    static var selectedSongNum: Int!
    static var songSelected = false
    static var soundLibraryList = SoundLibraryHelper.getSoundsFromLibraryPath(directory: "Sounds_Extra/")
}
