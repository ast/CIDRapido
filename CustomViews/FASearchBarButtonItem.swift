//
//  FASearchBarButtonItem.swift
//  CID-10
//
//  Created by Albin Stigö on 20/06/15.
//  Copyright © 2015 Albin Stigo. All rights reserved.
//

import UIKit

@IBDesignable public class FASearchBarButtonItem: FABarButtonItem {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fontAwesome = .Search
    }
}