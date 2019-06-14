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
        case authFailed = -1
        case response = 0
        case command = 2
        case auth = 3
    }
    
    private(set) var id: Int32
    private(set) var type: Type
    private(set) var body: String
    
    var data: [UInt8] {
        get {
            var bytes = [UInt8]()
            bytes.append(contentsOf: id.littleEndianBytes)
            bytes.append(contentsOf: type.rawValue.littleEndianBytes)
            if let body = body.data(using: .isoLatin1) {
                bytes.append(contentsOf: body)
            }
            bytes.append(0x00)
            bytes.append(0x00)
            let size: Int32 = Int32(bytes.count)
            bytes.insert(contentsOf: size.littleEndianBytes, at: 0)
            return bytes
        }
    }
    
    init(id: Int32, type: Type, body: String) {
        self.id = id
        self.type = type
        self.body = body
    }
    
    init?(bytes: [UInt8]) {
        if  let size = [UInt8](bytes[0...3]).readInt32LittenEndian(), size >= 10,
            let id = [UInt8](bytes[4...7]).readInt32LittenEndian(),
            let typeRawValue = [UInt8](bytes[8...11]).readInt32LittenEndian(),
            let type = Type(rawValue: typeRawValue),
            let body = String(bytes: [UInt8](bytes[12..<Int(size + 3)]), encoding: .utf8) {
                self.id = id
                self.type = type
                self.body = body
        } else {
            return nil
        }
    }
}

extension Array where Element == UInt8 {
    func readInt32LittenEndian() -> Int32? {
        guard self.count == 4 else {
            return nil
        }
        var ret: Int32 = 0
        var count = 0
        repeat {
            ret |= Int32(self[count]) << (count * UInt8.bitWidth)
            count += 1
        } while (count < 4)
        return ret
    }
}
