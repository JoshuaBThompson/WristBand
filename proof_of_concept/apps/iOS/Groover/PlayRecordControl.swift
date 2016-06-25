//
//  PlayRecordControl.swift
//  Groover
//
//  Created by Joshua Thompson on 6/15/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit


class PlayRecordControl: UIControl {
    var buttons = [PlayRecordButton]()
    var spacing = 15
    var count = 3
    var currentButtonNum = 0
    var currentButtonType = PlayRecordButtonTypes_t.PLAY
    var playButton: PlayRecordButton!
    var clearButton: PlayRecordButton!
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
    
    func addButton(button: PlayRecordButton){
        button.addTarget(self, action: #selector(PlayRecordControl.playRecordButtonTapped(_:)), forControlEvents: .TouchDown)
        buttons += [button]
        addSubview(button)
    }
    
    func addSubviews(){
            playButton = Play()
            playButton.type = .PLAY
            addButton(playButton)
        
            clearButton = Clear()
            clearButton.type = .CLEAR
            addButton(clearButton)
        
            recordButton = Record()
            recordButton.type = .RECORD
            addButton(recordButton)
            
            //button.adjustsImageWhenHighlighted = false
        
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        let buttonSpacing = Int(frame.size.width) / count
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in buttons.enumerate() {
            //buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            buttonFrame.origin.x = CGFloat(index * (buttonSpacing) + spacing)
            //buttonFrame.size.width = buttonFrame.size.width
            //buttonFrame.size.height = buttonFrame.size.height
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * count
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func playRecordButtonTapped(button: PlayRecordButton) {
        currentButtonNum = buttons.indexOf(button)!
        currentButtonType = PlayRecordButtonTypes_t(rawValue: currentButtonNum)!
        print("Play or Record button tapped")
        updateButtonSelectionStates()
        sendActionsForControlEvents(.ValueChanged) //this tells view controller that something changed
        
    }
    func manualSelectButton(buttonType: PlayRecordButtonTypes_t){
        currentButtonType = buttonType
        let num = currentButtonType
        
        //just select button, don't deselect others
        switch num {
        case .PLAY:
            print("play manually selected")
            playButton.selected = true
            playButton.on = true
            playButton.set = true
            playButton.updateState()
            
        case .CLEAR:
            print("clear manually selected")
            clearButton.selected = true
            clearButton.on = true
            clearButton.set = true
            clearButton.updateState()
            
        case .RECORD:
            print("record manually selected")
            recordButton.selected = true
            recordButton.on = true
            recordButton.set = true
            recordButton.updateState()
        }

    }
    
    func updateButtonSelectionStates() {
        let num = currentButtonType //PlayRecordButtonTypes_t(rawValue: currentButtonNum)!
        switch num {
            case .PLAY:
                print("play selected")
                playButton.selected = !playButton.selected
                recordButton.selected = false
                clearButton.selected = false
            
            case .CLEAR:
                print("clear selected")
                clearButton.selected = false
            
            case .RECORD:
                print("record selected")
                recordButton.selected = !recordButton.selected
                clearButton.selected = recordButton.selected
                playButton.selected = false
        }
        
        for (_, button) in buttons.enumerate(){
            button.on = button.selected
            button.set = button.selected
            button.updateState()
        }
        
        
        
        
        
    }
    
    
}
