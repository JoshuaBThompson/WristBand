//
//  DeleteSongCtrl.swift
//  Groover
//
//  Created by Joshua Thompson on 1/22/17.
//  Copyright © 2017 TCM. All rights reserved.
//

import UIKit

class DeleteSongCtrl: DeleteSong {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
        
    }
    
    func buttonTapped(){
        print("delete song button tapped")
        sendActions(for: .valueChanged) //this tells view controller that something changed
    }

}

