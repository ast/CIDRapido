//
//  RowTableViewCell.swift
//  CID-10
//
//  Created by Albin Stigo on 26/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import UIKit

class RowCell: UITableViewCell {

    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var codeLabelWidthConstraint: NSLayoutConstraint!
    
    var codeLabelWidth : CGFloat {
        get {
            return codeLabelWidthConstraint.constant
        }
        set {
            codeLabelWidthConstraint.constant = newValue
        }
    }

}
