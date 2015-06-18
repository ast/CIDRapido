//
//  String+path.swift
//  CID-10
//
//  Created by Albin Stigö on 12/06/15.
//  Copyright © 2015 Albin Stigo. All rights reserved.
//

import Foundation

extension String {
    func pathForFile(filename: String, ofType type: String) -> String? {
        return self.stringByAppendingPathComponent(filename).stringByAppendingPathExtension(type)
    }
}