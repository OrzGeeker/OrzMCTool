//
//  MCQuery.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/22.
//  Copyright © 2019 joker. All rights reserved.
//
//  Reference:
//      - [Query](https://wiki.vg/Query)
//      - [SwiftSocket](https://github.com/swiftsocket/SwiftSocket)
//

import SwiftSocket

open class MCQuery {
    
    static let defautlQueryPort: Int32 = 25565
    
    // 主机地址/域名
    var host: String
    // 端口号
    var port: Int32
    // UDPSocket 客户端
    var client: UDPClient
    // token
    var token: Int32?
    // 会话ID
    var sessionID: Int32
    
    /// 初始化一个MCQuery查询实例
    ///
    /// - Parameters:
    ///   - host: 查询的MC服务器主机，可以是域名或者ip地址
    ///   - port: 端口号
    init(host: String, port: Int32 = MCQuery.defautlQueryPort) {
        self.host = host
        self.port = port
        self.client = UDPClient(address: self.host, port: self.port)
        self.sessionID = 1
    }
    
    /// 与Minecraft服务器进行握手，建立UDP连接
    func handshake() {
        let handshakeRequest = Request(sessionID: self.sessionID)
        switch self.client.send(data: handshakeRequest.packet()) {
        case .success:
            let (bytes, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let data = bytes, let response = Response(data) {
                let tokenString = String(cString: response.payload) as NSString
                self.token = tokenString.intValue
                print("handshake successfully!(token: \(tokenString.intValue))")
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    
    /// 查询Minecraft服务器基本状态
    open func basicStatus() -> MCServerBasicStatus? {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return nil
        }
        
        let basicStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: token.bigEndianBytes)
        switch self.client.send(data: basicStatusRequest.packet()) {
        case .success:
            let (bytes, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let data = bytes, let basicStatus = Response(data)?.parseBasicStatus() {
                return basicStatus
            } else {
                print("handshake failed!")
                return nil
            }
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    /// 查询Minecraft服务器详情状态
    open func fullStatus() -> MCServerFullStatus? {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return nil
        }
        var payload = [Byte]()
        payload.append(contentsOf: token.bigEndianBytes)
        payload.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        let fullStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: payload)
        switch self.client.send(data: fullStatusRequest.packet()) {
        case .success:
            let (bytes, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let data = bytes, let fullStatus = Response(data)?.parseFullStatus() {
                return fullStatus
            } else {
                print("handshake failed!")
                return nil
            }
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    deinit {
        // 关闭Socket UDP连接
        self.client.close()
    }
}
