//
//  Array+partition.swift
//  CID-10
//
//  Created by Albin Stigö on 28/12/14.
//  Copyright (c) 2014 Albin Stigo. All rights reserved.
//

import Foundation

internal extension Array {
    
    func partition (n: Int) -> [Array] {

        var res = [Array]()
        
        for i in 0.stride(through: count - 1, by: n) {
        
            let a = Array(self[i..<(i+n)])
            res.append(a)
        }
        
        return res
    }
}