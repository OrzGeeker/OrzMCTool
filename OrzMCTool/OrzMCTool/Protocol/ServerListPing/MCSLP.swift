//
//  MCSLP.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/10.
//  Copyright © 2019 joker. All rights reserved.
//
//  Reference:
//      - [SLP](https://wiki.vg/Server_List_Ping)
//      - [SwiftSocket](https://github.com/swiftsocket/SwiftSocket)
//      - SLP使用TCP链接

import Foundation
import SwiftSocket

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
    var client: TCPClient
    
    /// 初始化一个SLP查询实例
    ///
    /// - Parameters:
    ///   - host: 查询的MC服务器主机，可以是域名或者ip地址
    ///   - port: 端口号
    init(host: String, port: Int32 = MCSLP.defaultPort) {
        self.host = host
        self.port = port
        self.client = TCPClient(address: self.host, port: self.port)
    }
    
    
    func handshake() throws {
        switch self.client.connect(timeout: 5) {
        case .success:
            let handshakePacket = MCPacket()
            handshakePacket.writeID(0x00)
            handshakePacket.writeVarInt(value: -1)
            handshakePacket.writeString(value: host)
            handshakePacket.writeUnsignedShort(value: UInt16(port))
            handshakePacket.writeVarInt(value: 1)
            handshakePacket.encapsulate()
            switch self.client.send(data: handshakePacket.data) {
            case .success:
                break
            case .failure(let error):
                throw MCError.handshakeFailed(error)
            }
        case .failure(let error):
            throw MCError.connectFailed(error)
        }
    }
    
    func status() throws -> (status: String?, ping: Int) {
        let requestPacket = MCPacket()
        requestPacket.writeID(0x00)
        requestPacket.encapsulate()
        
        switch self.client.send(data: requestPacket.data) {
        case .success:
            usleep(400000)
            guard let data = self.client.read(MCSLP.BUFF_SIZE_40K, timeout: 5) else {
                throw MCError.checkStatusTimeout
            }
            
            let reponse = MCPacket(bytes: data)
            // PacketLength
            let _ = try! reponse.readVarInt()
            // packetID
            let _ = reponse.readID()
            // JSON String
            let jsonStr = reponse.readString()
            
            let ping = try self.ping()
            return (status: jsonStr, ping: ping)
            
        case .failure(let error):
            throw MCError.checkStatusFailed(error)
        }
    }
    
    func ping() throws -> Int {
        
        let pingPacket = MCPacket()
        pingPacket.writeID(0x01)
        pingPacket.writeLong(value: Int64.max)
        pingPacket.encapsulate()
        
        let startTime = Date()
        switch self.client.send(data: pingPacket.data) {
        case .success:
            guard let data = self.client.read(MCSLP.BUFF_SIZE_1K, timeout: 5) else {
                throw MCError.pingTimeout
            }
            let pongPacket = MCPacket(bytes: data)
            if pingPacket == pongPacket {
                let milliSeconds = Int(Date().timeIntervalSince(startTime) * 1000)
                return milliSeconds
            } else {
                throw MCError.pingFailed(nil)
            }
        case .failure(let error):
            throw MCError.pingFailed(error)
        }
    }
    
    deinit {
         self.client.close()
    }
}
