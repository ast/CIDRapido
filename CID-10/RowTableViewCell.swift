//
//  RowTableViewCell.swift
//  CID-10
//
//  Created by Albin Stigo on 26/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import UIKit

class RowTableViewCell: UITableViewCell {

    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
