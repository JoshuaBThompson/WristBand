//
//  SongListTableViewCell.swift
//  Groover
//
//  Created by Joshua Thompson on 12/20/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

protocol SongCellDelegate: class {
    func selectSong(num: Int)
    func deleteSong(num: Int)
    
}

class SongListTableViewCell: UITableViewCell {
    //MARK: Properties
    weak var delegate: SongCellDelegate?
    var num: Int = 0
    
    @IBOutlet weak var songNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

