//
//  SoundLibraryHelper.swift
//  Groover
//
//  Created by Joshua Thompson on 2/11/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation

class SoundLibraryHelper {
    static let fileManager = FileManager.default
    
    //MARK: Init
    init(){
        
    }
    
    //MARK: Get list of sounds from path
    func getSoundsFromLibraryPath(directory: String)->[String]{
        let sound_lib_paths = Bundle.main.paths(forResourcesOfType: "wav", inDirectory: directory)
        return sound_lib_paths
    }
    
    func getSoundFileNameFromPath(path: String)->String{
        return path.fileName()
    }
}

extension String {
    
    func fileName() -> String {
        
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
}
