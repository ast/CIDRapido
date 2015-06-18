//
//  BrowseCell.swift
//  CID-10
//
//  Created by Albin Stigo on 11/01/15.
//  Copyright (c) 2015 Albin Stigo. All rights reserved.
//

import UIKit

class BrowseCell: UITableViewCell {

    @IBOutlet var bar: UIView!
    @IBOutlet var code: UILabel!
    @IBOutlet var codeWidth: NSLayoutConstraint!
    @IBOutlet var desc: UILabel!
    
    var childCount : Int = 0 {
        didSet {
            selectionStyle = childCount > 0 ? .Default : .None
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateBackground()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBackground()
    }
    
    private func updateBackground() {
        bar.backgroundColor = childCount > 0 ? UIColor.lightHospitalGreen() : UIColor.lightGrayColor()
    }
}
