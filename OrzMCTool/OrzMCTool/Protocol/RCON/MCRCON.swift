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
    
    func login() {
        
    }
    
    func logout() {
        
    }
    
    func sendCmd() {
        
    }
}
