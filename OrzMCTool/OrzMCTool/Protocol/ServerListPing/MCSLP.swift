//
//  MCSLP.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/10.
//  Copyright © 2019 joker. All rights reserved.
//
//  Reference:
//      - [SLP](https://wiki.vg/Server_List_Ping)
//      - SLP使用TCP链接

import Foundation
import Socket

open class MCSLP {
    static let BUFF_SIZE_1K = 1024                          // 1K
    static let BUFF_SIZE_4K = 4 * MCSLP.BUFF_SIZE_1K        // 4K
    static let BUFF_SIZE_40K = 40 * MCSLP.BUFF_SIZE_1K      // 40K
    static let defaultPort: Int32 = 25565
    // 主机地址/域名
    var host: String
    // 端口号
    var port: Int32
    // TCP Socket
    var client: Socket?
    
    /// 初始化一个SLP查询实例
    ///
    /// - Parameters:
    ///   - host: 查询的MC服务器主机，可以是域名或者ip地址
    ///   - port: 端口号
    init(host: String, port: Int32 = MCSLP.defaultPort) {
        self.host = host
        self.port = port
        self.client = try? Socket.create()
    }
    
    
    func handshake() throws {
        
        guard let client = self.client else {
            print("Socket 创建失败")
            return
        }
        do {
            try client.connect(to: self.host, port: self.port)
            let handshakePacket = MCPacket()
            handshakePacket.writeID(0x00)
            handshakePacket.writeVarInt(value: -1)
            handshakePacket.writeString(value: host)
            handshakePacket.writeUnsignedShort(value: UInt16(port))
            handshakePacket.writeVarInt(value: 1)
            handshakePacket.encapsulate()
            try client.write(from: Data(handshakePacket.data))
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    func status() throws -> (status: String?, ping: Int) {
        
        guard let client = self.client else {
            print("Socket 创建失败")
            return (nil,0)
        }
        
        let requestPacket = MCPacket()
        requestPacket.writeID(0x00)
        requestPacket.encapsulate()
        
        do {
            try client.write(from: Data(requestPacket.data))
            usleep(400000)
            
            var data = Data()
            _ = try client.read(into: &data)
            
            
            let bytes = [Byte](data)
            let reponse = MCPacket(bytes: bytes)
            // PacketLength
            let _ = try! reponse.readVarInt()
            // packetID
            let _ = reponse.readID()
            // JSON String
            let jsonStr = reponse.readString()
            
            let ping = try self.ping()
            return (status: jsonStr, ping: ping)
        } catch let error {
            print("\(error.localizedDescription)")
            return (nil,0)
        }
    }
    
    func ping() throws -> Int {
        
        guard let client = self.client else {
            print("Socket 创建失败")
            return 0
        }
        
        do {
        
            let pingPacket = MCPacket()
            pingPacket.writeID(0x01)
            pingPacket.writeLong(value: Int64.max)
            pingPacket.encapsulate()
            
            let startTime = Date()
            
            try client.write(from: Data(pingPacket.data))
            
            var data = Data()
            _ = try client.read(into: &data)
            let bytes = [Byte](data)
            let pongPacket = MCPacket(bytes: bytes)
            if pingPacket == pongPacket {
                let milliSeconds = Int(Date().timeIntervalSince(startTime) * 1000)
                return milliSeconds
            } else {
                throw MCError.pingFailed(nil)
            }
        } catch let error {
            print("\(error.localizedDescription)")
            return 0
        }
    }
    
    deinit {
        client?.close()
    }
}
