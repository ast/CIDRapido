//
//  ASTSearchButton.swift
//  CID-10
//
//  Created by Albin Stigö on 17/01/15.
//  Copyright (c) 2015 Albin Stigo. All rights reserved.
//

import UIKit

class ASTSearchButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let label = self.titleLabel!
        
        label.font = UIFont(name: "FontAwesome", size: 22.0)
        label.text = "\u{f002}"
        
        label.textColor = UIColor.whiteColor()
        label.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        
        label.shadowOffset = CGSizeMake(1, 1)
        
    }
}
