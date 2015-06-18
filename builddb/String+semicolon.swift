//
//  NSString+semicolon.swift
//  CID-10
//
//  Created by Albin Stigö on 17/06/15.
//  Copyright © 2015 Albin Stigo. All rights reserved.
//

import Foundation

extension String {
    
    func componentsSeparatedBySemicolon() -> [String] {
        return self.componentsSeparatedByString(";")
    }
}