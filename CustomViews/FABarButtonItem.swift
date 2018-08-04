//
//  FABarButtonItem.swift
//  CID-10
//
//  Created by Albin Stigö on 20/06/15.
//  Copyright © 2015 Albin Stigo. All rights reserved.
//

import UIKit

public enum FontAwesome : String {
    case Facebook = "\u{f230}"
    case Twitter = "\u{f081}"
    case Email = "\u{f199}"
    case Info = "\u{f05a}"
    case Search = "\u{f002}"
}

@IBDesignable public class FABarButtonItem: UIBarButtonItem {

    @IBInspectable public var fontAwesome : FontAwesome? {
        get {
            if let title = self.title {
                return FontAwesome(rawValue: title)
            }
            return nil
        }
        set {
            self.title = newValue?.rawValue
        }
    }
    
    private func setupFont() {
        let attrs = [NSFontAttributeName : UIFont(name: "FontAwesome", size: 24) as! AnyObject]
        setTitleTextAttributes(attrs, forState:UIControlState.Normal)
    }
    
    public init(fontAwesome: FontAwesome) {
        super.init()
        setupFont()
        
        self.fontAwesome = fontAwesome
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFont()
    }
}
