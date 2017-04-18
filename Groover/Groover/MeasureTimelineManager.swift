//
//  MeasureTimelineManager.swift
//  Groover
//
//  Created by Joshua Thompson on 4/9/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import Foundation
import UIKit

class MeasureTimelineManager {
    //MARK: Attributes
    var measureViews: [MeasureCtrl]!
    var measureLabels: [UILabel]!
    var needsClear = false
    var song: Song!
    
    
    //MARK: Init
    init(measure_views: [MeasureCtrl], measure_labels: [UILabel]){
        measureViews = measure_views
        measureLabels = measure_labels
        song = GlobalAttributes.song
    }
    
    
    //MARK: Functions
    func isReadyForUpdate()->Bool{
        if(!song.playing){
            //print("meaasureTimeerHandler - not playing")
            //clearTimelineIfNeedsClear()
            return false
        }
        
        let ready = song.updateMeasureTimeline()
        if(!ready){
            //print("meaasureTimeerHandler - not ready")
            //clearTimelineIfNeedsClear()
            return false
        }
        
        return true
    }
    
    func updateMeasureTimeline(){
        let bar_num = song.timeline.bar_num
        let prev_bar_num = song.timeline.prev_bar_num
        let bar_progress = song.timeline.current_progress
        let ready_to_clear = song.timeline.ready_to_clear
        if(ready_to_clear){
            clearTimelineProgress()
        }
        measureViews[bar_num].exists = true
        measureViews[bar_num].active = true
        measureViews[bar_num].updateMeasureProgress(progress_prcnt: CGFloat(bar_progress))
        
        let measure_count = song.instrument.loop.current_measure + 1
        
        let label_num_str = "\(measure_count)"
        if(label_num_str != measureLabels[bar_num].text){
            measureLabels[bar_num].text = label_num_str
        }
        if(prev_bar_num < bar_num || ((bar_num == 0) && (prev_bar_num > 0))){
            //fill in prev bar num to 100% just in case
            measureViews[prev_bar_num].updateMeasureProgress(progress_prcnt: CGFloat(1.0))
            measureViews[prev_bar_num].active = false
        }
        needsClear = true //used when song is stopped, check if this is set and clear again
        
    }
    
    func clearTimelineProgress(){
        
    }
}
