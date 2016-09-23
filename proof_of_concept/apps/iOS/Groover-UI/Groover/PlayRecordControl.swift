//
//  PlayRecordControl.swift
//  Groover
//
//  Created by Joshua Thompson on 7/12/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import Foundation

import UIKit


class PlayRecordControl: UIControl {
    var buttons = [PlayRecordButton]()
    var spacing = 15
    var count = 3
    var currentButtonNum = 0
    var currentButtonType = PlayRecordButtonTypes_t.play
    var playButton: PlayRecordButton!
    var recordButton: PlayRecordButton!
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        
    }
    
    func addButton(_ button: PlayRecordButton){
        button.addTarget(self, action: #selector(PlayRecordControl.playRecordButtonTapped(_:)), for: .touchDown)
        buttons += [button]
        addSubview(button)
    }
    
    func addSubviews(){
        playButton = Play()
        playButton.type = .play
        addButton(playButton)
        
        recordButton = Record()
        recordButton.type = .record
        addButton(recordButton)
        
        //button.adjustsImageWhenHighlighted = false
        
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = 44
        let buttonSpacing = 128 / count
        var buttonFrame = CGRect(x:0, y: 5, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in buttons.enumerated() {
            //buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            buttonFrame.origin.x = CGFloat(index * (buttonSpacing) + spacing)
            //buttonFrame.size.width = buttonFrame.size.width
            //buttonFrame.size.height = buttonFrame.size.height
            button.frame = buttonFrame
        }
        //updateButtonSelectionStates()
    }
    
    override var intrinsicContentSize : CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * count
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func playRecordButtonTapped(_ button: PlayRecordButton) {
        currentButtonNum = buttons.index(of: button)!
        currentButtonType = PlayRecordButtonTypes_t(rawValue: currentButtonNum)!
        print("Play or Record button tapped")
        updateButtonSelectionStates()
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
    
    func manualSelectButton(_ buttonType: PlayRecordButtonTypes_t){
        currentButtonType = buttonType
        let num = currentButtonType
        
        //just select button, don't deselect others
        switch num {
        case .play:
            print("play manually selected")
            playButton.isSelected = true
            playButton.on = true
            playButton.set = true
            playButton.updateState()
            
        case .record:
            print("record manually selected")
            recordButton.isSelected = true
            recordButton.on = true
            recordButton.set = true
            recordButton.updateState()
        }
        
    }
    
    func manualDeselectButton(_ buttonType: PlayRecordButtonTypes_t){
        currentButtonType = buttonType
        let num = currentButtonType
        
        //just select button, don't deselect others
        switch num {
        case .play:
            print("play manually deselected")
            playButton.isSelected = false
            playButton.on = false
            playButton.set = false
            playButton.updateState()
            
        case .record:
            print("record manually deselected")
            recordButton.isSelected = false
            recordButton.on = false
            recordButton.set = false
            recordButton.updateState()
        }
        
    }
    
    func updateButtonSelectionStates() {
        let num = currentButtonType
        var changed = false
        switch num {
        case .play:
            print("play selected")
            playButton.isSelected = !playButton.isSelected
            if(!playButton.isSelected){
                recordButton.isSelected = false
            }
            changed = true
            
        case .record:
            
            //only change record button if play button is already selected
            if(playButton.isSelected){
                print("record selected")
                recordButton.isSelected = !recordButton.isSelected
                changed = true
            }
            else{
                changed = false
            }
        }
        
        if(changed){
        
            for (_, button) in buttons.enumerated(){
                button.on = button.isSelected
                button.set = button.isSelected
                button.updateState()
            }
        }
        
    }
    
    
}

