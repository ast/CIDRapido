//
//  ASTBarButtonItem.swift
//  CID-10
//
//  Created by Albin Stigö on 27/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import UIKit

@IBDesignable class ASTBarButtonItem: UIBarButtonItem {
   
    @IBOutlet var infoButton : UIButton? {
        didSet {
            self.customView = infoButton
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
