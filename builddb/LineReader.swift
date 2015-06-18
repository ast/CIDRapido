//
//  LineInputStream.swift
//  CID-10
//
//  Created by Albin Stigö on 17/06/15.
//  Copyright © 2015 Albin Stigo. All rights reserved.
//

import Foundation

class LineReader {
    
    private let lf: CChar = 0x0a // \n
    private let cr: CChar = 0x0d // \r
    private let inputStream : NSInputStream
    
    // Kind of like a golang slice
    class Buffer {
        let buf: UnsafeMutablePointer<CChar>
        let cap: Int // Allocated length
        var len: Int // Current number of characters
        var i: Int
        
        init(cap: Int) {
            self.buf = UnsafeMutablePointer<CChar>.alloc(cap)
            self.cap = cap
            self.len = 0
            self.i = 0
        }
        
        deinit {
            buf.destroy(cap)
        }
    }
    
    private let buffer : Buffer
    private let line : Buffer
    
    init(inputStream: NSInputStream) {
        self.inputStream = inputStream

        switch inputStream.streamStatus {
        case .NotOpen: inputStream.open()
        default: break
        }
        
        let bufferSize = 32 * 1024
        buffer = Buffer(cap: bufferSize)
        line = Buffer(cap: bufferSize)
    }
    
    func getc() -> CChar? {
        // If emtpy, try to read more from buffer
        if buffer.i == buffer.len {
            buffer.len = inputStream.read(UnsafeMutablePointer<UInt8>(buffer.buf), maxLength: buffer.cap)
            assert(buffer.len != -1, "Error reading")
            buffer.i = 0
        }
        
        if buffer.i < buffer.len {
            return buffer.buf[buffer.i++]
        }
        
        return nil
    }
    
    func readLine() -> String? {
        
        while let c = getc() {
            switch c {
            case self.cr: break // ignore
            case self.lf: // line break
                line.buf[line.len] = 0x00 // null termnination
                line.len = 0
                return String(UTF8String: line.buf)
            default: // c strings are null terminated so leave space.   
                assert(line.len < (line.cap - 1), "line too long")
                line.buf[line.len++] = c
            }
        }
        
        return nil
    }
}