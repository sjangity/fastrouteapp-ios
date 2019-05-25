//
//  AddressListTableViewCell.swift
//  FastRoute
//
//  Created by apple on 9/9/15.
//  Copyright (c) 2015-2019 Sandeep Jangity. All rights reserved.
//

import UIKit

class AddressListTableViewCell: UITableViewCell {

    @IBOutlet weak var addressPrimary: UILabel!
    @IBOutlet weak var addressDistance: UILabel!
    @IBOutlet weak var addressSecondary: UILabel!
    @IBOutlet weak var addressIcon: UIImageView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
