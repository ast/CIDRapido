//
//  String+range.swift
//  CID-10
//
//  Created by Albin Stigö on 28/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import Foundation

extension String {
    
    /* http://stackoverflow.com/questions/7407284/detect-character-position-in-an-utf-nsstring-from-a-byte-offsetwas-sqlite-offse */
    
    func charRangeForByteRange(range : NSRange) -> NSRange {

        let bytes = [UInt8](utf8)
        
        var charOffset = 0
        
        for i in 0..<range.location {
            if ((bytes[i] & 0xc0) != 0x80) { charOffset++ }
        }
        
        let location = charOffset

        for i in range.location..<(range.location + range.length) {
            if ((bytes[i] & 0xc0) != 0x80) { charOffset++ }
        }
        
        let length = charOffset - location

        return NSMakeRange(location, length)
    }
}