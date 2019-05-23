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

class MCQuery {
    
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
    init(host: String, port: Int32 = 25565) {
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
                if let tokenString = String(bytes: response.payload, encoding: .ascii) as NSString? {
                    self.token = tokenString.intValue
                    print("handshake successfully!(token: \(tokenString.intValue))")
                }
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    
    /// 查询Minecraft服务器基本状态
    func basicStatus() {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return
        }
        
        let basicStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: token.bigEndianBytes)
        switch self.client.send(data: basicStatusRequest.packet()) {
        case .success:
            let (bytes, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let data = bytes, let basicStatus = Response(data)?.parseBasicStatus() {
                print("basic status: \(basicStatus)")
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    
    /// 查询Minecraft服务器详情状态
    func fullStatus() {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return
        }
        var payload = [Byte]()
        payload.append(contentsOf: token.bigEndianBytes)
        payload.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        let fullStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: payload)
        switch self.client.send(data: fullStatusRequest.packet()) {
        case .success:
            let (bytes, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let data = bytes, let fullStatus = Response(data)?.parseFullStatus() {
                print("full status: \(fullStatus)")
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    
    deinit {
        // 关闭Socket UDP连接
        self.client.close()
    }
}


// MARK: - Minecraft Query协议请求和响应包格式处理
extension MCQuery {
    
    // 设置UDP接收缓存
    static let BUFF_SIZE = 4 * 1024
    
    enum `Type`: Byte {
        case handshake = 0x09
        case status = 0x00
        case unknowned = 0xFF
    }
    
    // Minecraft Query协议请求包格式定义和处理
    struct Request {
        private let magic: [Byte] = [0xFE, 0xFD]
        let type: Type
        let sessionID: [Byte]
        let payload: [Byte]?
        
        init(type: Type = .handshake, sessionID: Int32, payload: [Byte]? = nil) {
            self.type = type
            self.sessionID = sessionID.sessionIDBytes
            self.payload = payload
        }
        
        func packet() -> [Byte] {
            var bytes = [Byte]()
            bytes.append(contentsOf: self.magic)
            bytes.append(self.type.rawValue)
            bytes.append(contentsOf: self.sessionID)
            if let payload = self.payload {
                bytes.append(contentsOf: payload)
            }
            return bytes
        }
    }
    
    // Minecraft Query协议响应包格式定义和处理
    struct Response {
        
        let type: Type
        let sessionID: [Byte]
        let payload: [Byte]
    
        init? (_ data: [Byte]) {
            if(data.count >= 5) {
                self.type = Type(rawValue: data[0]) ?? Type.unknowned
                self.sessionID = [Byte](data[1..<5])
                self.payload = [Byte](data[5..<data.count])
            } else {
                return nil
            }
        }
        
        
        /// 从响应数据中提取服务器基础信息字符串
        ///
        /// - Returns: 服务器基础信息字符串数组
        func parseBasicStatus() -> MCServerBasicStatus? {
            var statusInfo = [String]()
            if(self.type == .status) {
                var lastIndex = 0
                for (index, byte) in payload.enumerated() {
                    if(statusInfo.count == 5) {
                        let hostport = UInt16(payload[index + 1]) << 8 | UInt16(payload[index])
                        statusInfo.append(String(hostport))
                        lastIndex = index + 2
                        continue
                    }
                    
                    if(byte == 0x00) {
                        if let value = String(bytes: [Byte](payload[lastIndex...index]), encoding: .ascii) {
                            statusInfo.append(value)
                        }
                        lastIndex = index + 1
                    }
                }
            }
            guard statusInfo.count == 7 else {
                return nil;
            }
            
            return MCServerBasicStatus(
                MOTD: statusInfo[0],
                gameType: statusInfo[1],
                map: statusInfo[2],
                numplayers: statusInfo[3],
                maxplayers: statusInfo[4],
                hostport: Int16((statusInfo[5] as NSString).intValue),
                hostip: statusInfo[6]
            )
        }
        
        
        /// 从响应数据中提取服务器详细信息
        func parseFullStatus () -> MCServerFullStatus?{
            let paddingCount = 11
            if(self.type == .status) {
                var keyValueInfo = [String]()
                var lastIndex = 0
                let invalidPayload = [Byte](payload[paddingCount..<payload.count])
                for (index, byte) in invalidPayload.enumerated() {
                    
                    if(byte == 0x00) {
                        if let value = String(bytes: [Byte](invalidPayload[lastIndex...index]), encoding: .ascii) {
                            keyValueInfo.append(value)
                        }
                        lastIndex = index + 1
                        if(invalidPayload[lastIndex] == 0x00) {
                            lastIndex += paddingCount
                            break
                        }
                    }
                }

                var playersInfo = [String]()
                let playerSection = [Byte](invalidPayload[lastIndex..<invalidPayload.count])
                lastIndex = 0
                for (index, byte) in playerSection.enumerated() {
                    
                    if(byte == 0x00) {
                        if let value = String(bytes: [Byte](playerSection[lastIndex...index]), encoding: .ascii) {
                            playersInfo.append(value)
                        }
                        lastIndex = index + 1
                        if(playerSection[lastIndex] == 0x00) {
                            break
                        }
                    }
                }
                
                var infoDict = [String: String]()
                for (index, value) in keyValueInfo.enumerated() {
                    if(index % 2 == 0) {
                        infoDict[value] = keyValueInfo[index + 1]
                    } else {
                        continue
                    }
                }
                return MCServerFullStatus(
                    hostname: infoDict["hostname\0"] ?? "",
                    gameType: infoDict["gametype\0"] ?? "",
                    gameId: infoDict["game_id\0"] ?? "",
                    version: infoDict["version\0"] ?? "",
                    plugins: infoDict["plugins\0"] ?? "",
                    map: infoDict["map\0"] ?? "",
                    numplayers: infoDict["numplayers\0"] ?? "",
                    maxPlayers: infoDict["maxplayers\0"] ?? "",
                    hostPort: infoDict["hostport\0"] ?? "",
                    hostIP: infoDict["hostip\0"] ?? "",
                    players: playersInfo
                )
            }
            return nil
        }
    }
}
