//
//  MCQuery.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/22.
//  Copyright © 2019 joker. All rights reserved.
//
//  Reference:
//      - [Query](https://wiki.vg/Query)
//      - Query协议使用UDP
//

import Foundation
import Socket

open class MCQuery {
    
    static let defaultQueryPort: Int32 = 25565
    
    // 主机地址/域名
    var host: String
    // 端口号
    var port: Int32
    // UDPSocket 客户端
    var client: Socket?
    // token
    var token: Int32?
    // 会话ID
    var sessionID: Int32
    
    /// 初始化一个MCQuery查询实例
    ///
    /// - Parameters:
    ///   - host: 查询的MC服务器主机，可以是域名或者ip地址
    ///   - port: 端口号
    init(host: String, port: Int32 = MCQuery.defaultQueryPort) {
        self.host = host
        self.port = port
        self.client = try? Socket.create(family: .inet, type: .datagram, proto: .udp)
        self.sessionID = 1
    }
    
    /// 与Minecraft服务器进行握手，建立UDP连接
    func handshake() {
        
        guard let client = self.client else {
            print("创建Socket失败")
            return
        }
        
        do {
            try client.connect(to: self.host, port: self.port)
            let handshakeRequest = Request(sessionID: self.sessionID)
            try client.write(from: Data(handshakeRequest.packet()))
            
            var data = Data()
            _ = try client.read(into: &data)
            
            let bytes = [Byte](data)
            if let response = Response(bytes), let tokenLatin1String = response.payload.queryString()  {
                let tokenString = tokenLatin1String as NSString
                print("handshake successfully!(token: \(tokenLatin1String))")
                self.token = tokenString.intValue
            } else {
                print("handshake failed!")
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    
    /// 查询Minecraft服务器基本状态
    open func basicStatus() -> MCServerBasicStatus? {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return nil
        }
        
        guard let client = self.client else {
            print("创建Socket失败")
            return nil
        }
        
        let basicStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: token.bigEndianBytes)
        do {
            try client.write(from: Data(basicStatusRequest.packet()))
            
            var data = Data()
            _ = try client.read(into: &data)
            let bytes = [Byte](data)
            if let basicStatus = Response(bytes)?.parseBasicStatus() {
                return basicStatus
            } else {
                print("handshake failed!")
                return nil
            }
        } catch let error {
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// 查询Minecraft服务器详情状态
    open func fullStatus() -> MCServerFullStatus? {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return nil
        }
        
        guard let client = self.client else {
            print("创建Socket失败")
            return nil
        }
        
        var payload = [Byte]()
        payload.append(contentsOf: token.bigEndianBytes)
        payload.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        let fullStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: payload)
        
        do {
            try client.write(from: Data(fullStatusRequest.packet()))
            var data = Data()
            try _ = client.read(into: &data)
            let bytes = [Byte](data)
            if let fullStatus = Response(bytes)?.parseFullStatus() {
                return fullStatus
            } else {
                print("handshake failed!")
                return nil
            }
        } catch let error {
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    
    deinit {
        // 关闭Socket UDP连接
        client?.close()
    }
}
