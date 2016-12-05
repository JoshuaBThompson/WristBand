//
//  SongTableViewCell.swift
//  Groover
//
//  Created by Alex Crane on 12/1/16.
//  Copyright © 2016 TCM. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    //MARK: Properties
    var num: Int = 0
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func selectSongButton(_ sender: UIButton) {
        print("song \(num) selected from cell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
