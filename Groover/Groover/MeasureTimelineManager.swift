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
    var needs_clear = false
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
            return false
        }
        
        let ready = song.updateMeasureTimeline()
        if(!ready){
            return false
        }
        
        return true
    }
    
    func updateViews(){
        let bar_progress = song.timeline.current_progress
        let measure_count = song.timeline.measure_count + 1
        let bar_num = song.timeline.bar_num
        let prev_bar_num = song.timeline.prev_bar_num
        
        let ready_to_clear = song.timeline.ready_to_clear
        if(ready_to_clear){
            clearTimelineProgress()
        }
        measureViews[bar_num].exists = true
        measureViews[bar_num].active = true
        measureViews[bar_num].updateMeasureProgress(progress_prcnt: CGFloat(bar_progress))
        
        
        let label_num_str = "\(measure_count)"
        if(label_num_str != measureLabels[bar_num].text){
            measureLabels[bar_num].text = label_num_str
        }
        
        if(prev_bar_num < bar_num || ((bar_num == 0) && (prev_bar_num > 0))){
            //fill in prev bar num to 100% just in case
            measureViews[prev_bar_num].updateMeasureProgress(progress_prcnt: CGFloat(1.0))
            measureViews[prev_bar_num].active = false
        }
        needs_clear = true //used when song is stopped, check if this is set
        
        
        //clear measures that are not part of the loop
        if((bar_num + song.timeline.bars_remaining) < measureViews.count){
            let last_bar_num = song.timeline.last_bar_num
            for i in (last_bar_num + 1) ..< measureViews.count {
                if(!measureViews[i].exists){
                    break
                }
                
                measureViews[i].clearProgress()
                measureViews[i].active = false
                measureViews[i].exists = false
                measureLabels[i].text = ""
            }
        }
        
        if(bar_num == 0){
            var last_bar_num = 0
            if((bar_num + song.timeline.bars_remaining) < measureViews.count){
                last_bar_num = song.timeline.last_bar_num
            }
            else{
                last_bar_num = measureViews.count - 1
            }
            
            var j = 0
            for i in bar_num + 1 ... last_bar_num {
                j += 1
                let text = "\(measure_count + j)"
                if(measureLabels[i].text == text){
                    measureViews[i].clearProgress()
                    measureViews[i].active = false
                    measureViews[i].exists = true
                    break
                }
                
                measureViews[i].clearProgress()
                measureViews[i].active = false
                measureViews[i].exists = true
                measureLabels[i].text = text
            }
        }
        
        
    }
    
    func clearTimelineProgress(){
        for measure_view in measureViews {
            measure_view.clearProgress()
        }
        
    }
    
    func showInactive(){
        let count = song.instrument.loop.measures
        let recorded = song.instrument.recorded
        
        clearTimeline()
        if(!recorded){
            return
        }
        print("show active timeline count \(count)")
        
        for i in 0..<count {
            if(i >= measureViews.count){
                break
            }
            else{
                measureViews[i].exists = true
                let label_num_str = "\(i + 1)"
                if(label_num_str != measureLabels[i].text){
                    measureLabels[i].text = label_num_str
                }
            }
        }
    }
    
    func clearTimelineIfNeedsClear(){
        if(needs_clear){
            clearTimeline()
        }
    }
    
    func clearTimeline(){
        clearTimelineProgress()
        needs_clear = false
        
        for measure_view in measureViews {
            measure_view.active = false
            measure_view.exists = false
        }
        
        for label in measureLabels {
            label.text = ""
        }
    }
}
