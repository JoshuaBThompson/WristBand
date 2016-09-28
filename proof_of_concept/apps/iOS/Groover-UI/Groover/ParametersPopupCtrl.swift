//
//  ParametersPopupCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 9/28/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

protocol ParametersHandlerDelegate: class {
    // Right button pressed
    func measureRightButtonTapped()
    
    // Left button pressed
    func measureLeftButtonTapped()
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
        measureLeftButton = leftButtonRef
        measureTitleLabel = measureTitleRef
        measureLabel = measureLabelRef
    }
    

    
    //MARK: Hide popup function
    func toggleHide(){
        isHidden = !isHidden //toggle true / false
    }
    
    func hide(){
        isHidden = true
    }
    
    func show(){
        isHidden = false
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
        print("measure left button tapped")
        decMeasure()
        updateMeasureString()
        selectedButton = measureLeftButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
        
    }
    
    func measureRightButtonTapped(){
        print("measure right button tapped")
        incMeasure()
        updateMeasureString()
        selectedButton = measureRightButton
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }

}
