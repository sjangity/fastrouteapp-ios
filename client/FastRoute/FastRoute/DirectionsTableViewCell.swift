//
//  DirectionsTableViewCell.swift
//  FastRoute
//
//  Created by apple on 9/17/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {

    @IBOutlet weak var directionsDistance: UILabel!
    @IBOutlet weak var directionsText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
