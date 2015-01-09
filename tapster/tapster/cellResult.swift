//
//  cellResult.swift
//  tapster
//
//  Created by Matthew Lewis on 08/01/2015.
//  Copyright (c) 2015 iD Foundry. All rights reserved.
//

import UIKit

class cellResult: UITableViewCell {

    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelLeftScore: UILabel!
    @IBOutlet weak var labelRightScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
