//
//  ParametersPopupCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/28/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

enum ParametersButtonTypes {
    case CLEAR
    case SOLO
    case MUTE
    case MEASURE_LEFT
    case MEASURE_RIGHT
}

typealias ParametersButtonTypes_t = ParametersButtonTypes

protocol ParametersHandlerDelegate: class {
    // Right button pressed
    func measureRightButtonTapped()
    
    // Left button pressed
    func measureLeftButtonTapped()
    
    // Solo button pressed
    func soloButtonTapped()
    
    // Clear button pressed
    func clearButtonTapped()
    
    // Mute button pressed
    func muteButtonTapped()
}

class MeasureRightButton: Right {
    weak var delegate: ParametersHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.measureRightButtonTapped()
    }
}

class MeasureLeftButton: Left {
    weak var delegate: ParametersHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.measureLeftButtonTapped()
    }
}

class SoloButton: UIButton {
    weak var delegate: ParametersHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.soloButtonTapped()
    }
}

class ClearButton: UIButton {
    weak var delegate: ParametersHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.clearButtonTapped()
    }
}

class MuteButton: UIButton {
    weak var delegate: ParametersHandlerDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.muteButtonTapped()
    }
}

@IBDesignable
class ParametersPopupCtrl: ParametersPopup, ParametersHandlerDelegate {
    
    var clearButton: UIButton!
    var soloButton: UIButton!
    var muteButton: UIButton!
    var measureRightButton: MeasureRightButton!
    var measureLeftButton: MeasureLeftButton!
    var measures = 1
    var measuresUpdated = false
    var measureTitleLabel: UILabel!
    var measureLabel: UILabel!
    var buttonTypeSelected = ParametersButtonTypes_t.CLEAR
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
        isHidden = true
    }
    
    func initButtonsAndLabels(clearButtonRef: UIButton, soloButtonRef: UIButton, muteButtonRef: UIButton, rightButtonRef: MeasureRightButton, leftButtonRef: MeasureLeftButton, measureTitleRef: UILabel, measureLabelRef: UILabel){
        clearButton = clearButtonRef
        soloButton = soloButtonRef
        muteButton = muteButtonRef
        measureRightButton = rightButtonRef
        measureRightButton.delegate = self
        measureLeftButton = leftButtonRef
        measureLeftButton.delegate = self
        measureTitleLabel = measureTitleRef
        measureLabel = measureLabelRef
    }
    

    
    //MARK: Hide popup function
    func toggleHide(){
        if(isHidden){
            isHidden = false //toggle true / false
        }
        else{
            isHidden = true
        }
    }
    
    func hide(){
        isHidden = true
        clearButton.isHidden = true
        soloButton.isHidden = true
        muteButton.isHidden = true
        measureRightButton.isHidden = true
        measureLeftButton.isHidden = true
        measureTitleLabel.isHidden = true
        measureLabel.isHidden = true
    }
    
    func show(){
        isHidden = false
        clearButton.isHidden = false
        soloButton.isHidden = false
        muteButton.isHidden = false
        measureRightButton.isHidden = false
        measureLeftButton.isHidden = false
        measureTitleLabel.isHidden = false
        measureLabel.isHidden = false
    }
    
    
    //MARK: update measure count functions
    
    func setMeasure(_ measureCount: Int){
        measures = measureCount
        updateMeasureString()
    }
    
    func updateMeasureString(){
        measureLabel.text = String(format: "\(measures)")
    }
    
    
    //MARK: increment / decrement measure count functions
    func incMeasure(){
        measures += 1
        measuresUpdated = true
    }
    
    func decMeasure(){
        measures -= 1
        //don't let measure count get below 1
        if(measures < 1){
            measures = 1
        }
        measuresUpdated = true
    }
    
    
    //MARK: measure arrow tapped functions
    func measureLeftButtonTapped(){
        buttonTypeSelected = .MEASURE_LEFT
        print("measure left button tapped")
        decMeasure()
        updateMeasureString()
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    func measureRightButtonTapped(){
        buttonTypeSelected = .MEASURE_RIGHT
        print("measure right button tapped")
        incMeasure()
        updateMeasureString()
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }
    
    // Solo button pressed
    func soloButtonTapped(){
        buttonTypeSelected = .SOLO
    }
    
    // Clear button pressed
    func clearButtonTapped(){
        buttonTypeSelected = .CLEAR
        
    }
    
    // Mute button pressed
    func muteButtonTapped(){
        buttonTypeSelected = .MUTE
        
    }

}
