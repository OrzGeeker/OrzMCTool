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
//      - [SwiftSocket](https://github.com/swiftsocket/SwiftSocket)
//      - RCON使用TCP
//

import SwiftSocket

open class MCRCON {
    
    static let defaultRCONPort: Int32 = 25575
    static let BUFF_SIZE_1K = 1024
    
    // 主机地址/域名
    var host: String
    // 端口号
    var port: Int32
    // TCPSocket 客户端
    var client: TCPClient
    // 请求 ID
    var requestID: Int32
    
    init(host: String, port: Int32 = MCRCON.defaultRCONPort) {
        self.host = host
        self.port = port
        self.client = TCPClient(address: host, port: port)
        self.requestID = 0
    }
    
    func loginAndSendCmd(password: String, cmd: String) throws -> String? {
        switch self.client.connect(timeout: 5) {
        case .success:
            let loginPacket = RCONPacket(id: self.requestID, type: .auth, body: password)
            switch self.client.send(data: loginPacket.data) {
            case .success:
                guard let data = self.client.read(MCRCON.BUFF_SIZE_1K, timeout: 5) else {
                    throw MCRCONError.authTimeout
                }
                if let response = RCONPacket(bytes: data) {
                    guard response.id == loginPacket.id, response.type == .command else {
                        throw MCRCONError.authFailed
                    }
                    let result = try self.sendCmd(cmd)
                    return result
                } else {
                    throw MCRCONError.packetMalFormat
                }
            case .failure(let error):
                 throw MCRCONError.sendCmdFailed(error)
            }
        case .failure(let error):
            throw MCRCONError.connectFailed(error)
        }
    }

    func sendCmd(_ cmd: String) throws -> String? {
        print("Send Command: \(cmd)")
        let commandPacket = RCONPacket(id: self.requestID, type: .command, body: cmd)
        switch self.client.send(data: commandPacket.data) {
        case .success:
            guard let data = self.client.read(MCRCON.BUFF_SIZE_1K, timeout: 5) else {
                throw MCRCONError.sendCmdTimeout
            }
            if let response = RCONPacket(bytes: data) {
                guard commandPacket.id == response.id, response.type == .response else {
                    throw MCRCONError.responseInvalid
                }
                let result = response.body
                return result
            } else {
                throw MCRCONError.packetMalFormat
            }
        case .failure(let error):
            throw MCRCONError.sendCmdFailed(error)
        }
    }
    
    deinit {
        self.client.close()
    }
}
