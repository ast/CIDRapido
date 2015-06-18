//
//  ChapterCell.swift
//  CID-10
//
//  Created by Albin Stigo on 11/01/15.
//  Copyright (c) 2015 Albin Stigo. All rights reserved.
//

import UIKit

class ChapterCell: UITableViewCell {

    @IBOutlet var bar: UIView!
    @IBOutlet var code: UILabel!
    @IBOutlet var desc: UILabel!
    @IBOutlet var cap: UILabel!
    
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
        bar.backgroundColor = UIColor.lightHospitalGreen()
    }
}
