//
//  MCRCON.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/12.
//  Copyright © 2019 joker. All rights reserved.
//
//  Reference:
//      - [RCON](https://wiki.vg/RCON)
//      - [Source RCON Protocol](https://developer.valvesoftware.com/wiki/Source_RCON_Protocol)
//      - RCON使用TCP
//

import Foundation
import Socket

open class MCRCON {
    
    static let defaultRCONPort: Int32 = 25575
    static let BUFF_SIZE_1K = 1024
    
    // 主机地址/域名
    var host: String
    // 端口号
    var port: Int32
    // TCPSocket 客户端
    var client: Socket?
    // 请求 ID
    var requestID: Int32
    
    init(host: String, port: Int32 = MCRCON.defaultRCONPort) {
        self.host = host
        self.port = port
        self.client = try? Socket.create()
        self.requestID = 0
    }
    
    func loginAndSendCmd(password: String, cmd: String) throws -> String? {
        
        guard let client = self.client else {
            print("Socket创建失败")
            return nil
        }
        
        do {
            try client.connect(to: self.host, port: self.port, timeout: 5, familyOnly: true)
            let loginPacket = RCONPacket(id: self.requestID, type: .auth, body: password)   
            try client.write(from: Data(loginPacket.data))
            
            var data = Data()
            _ = try client.read(into: &data)
            
            let bytes = [UInt8](data)
            if let response = RCONPacket(bytes: bytes) {
                guard response.id == loginPacket.id, response.type == .command else {
                    throw MCRCONError.authFailed
                }
                let result = try self.sendCmd(cmd)
                return result
            } else {
                throw MCRCONError.packetMalFormat
            }
        } catch let error {
            print("\(error.localizedDescription)")
            return nil
        }
    }

    func sendCmd(_ cmd: String) throws -> String? {
        print("Send Command: \(cmd)")
        
        guard let client = self.client else {
            print("Socket创建失败")
            return nil
        }
        
        let commandPacket = RCONPacket(id: self.requestID, type: .command, body: cmd)
        do {
            try client.write(from: Data(commandPacket.data))
            
            var data = Data()
            _ = try client.read(into: &data)

            let bytes = [UInt8](data)
            if let response = RCONPacket(bytes: bytes) {
                guard commandPacket.id == response.id, response.type == .response else {
                    throw MCRCONError.responseInvalid
                }
                let result = response.body
                return result
            } else {
                throw MCRCONError.packetMalFormat
            }
        } catch let error {
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    deinit {
        client?.close()
    }
}
