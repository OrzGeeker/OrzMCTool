//
//  Int32+BigEndian.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/23.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

extension Int32 {
    public var bigEndianBytes: [UInt8] {
        var bigEndianBytes = [UInt8]()
        for i in (0 ..< 4).reversed() {
            let byte = UInt8(self >> (UInt8.bitWidth * i) & 0xFF)
            bigEndianBytes.append(byte)
        }
        return  bigEndianBytes
    }
    
    public var sessionIDBytes: [UInt8] {
        var bigEndianBytes = [UInt8]()
        for i in (0 ..< 4).reversed() {
            let byte = UInt8(self >> (UInt8.bitWidth * i) & 0x0F)
            bigEndianBytes.append(byte)
        }
        return  bigEndianBytes
    }
}
