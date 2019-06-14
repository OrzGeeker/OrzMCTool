//
//  RCONPacket.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/12.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

struct RCONPacket {
    
    enum `Type`: Int32 {
        case response = 0
        case command = 1
        case authResp = 2
        case auth = 3
    }
    
    var size: Int32
    var id: Int32
    var type: Int32
    var body: String
    
    var data: [UInt8] {
        var bytes = [UInt8]()
        bytes.append(contentsOf: size.littleEndianBytes)
        bytes.append(contentsOf: id.littleEndianBytes)
        bytes.append(contentsOf: type.littleEndianBytes)
        if let body = body.data(using: .isoLatin1) {
            bytes.append(contentsOf: body)
        }
        bytes.append(0x00)
        return bytes
    }
    
}
