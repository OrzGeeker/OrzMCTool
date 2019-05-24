//
//  MCQuery+Packet.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/24.
//  Copyright © 2019 joker. All rights reserved.
//
//  Minecraft Query协议请求和响应包格式处理

import Foundation

typealias Byte = UInt8

extension MCQuery {
    
    // 设置UDP接收缓存
    static let BUFF_SIZE = 4 * 1024
    
    enum `Type`: Byte {
        case handshake = 0x09
        case status = 0x00
        case unknowned = 0xFF
    }
    
    enum MCError {
        case handshakeFailed
        case parseStatusFailed
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
                        let value = String(cString: [Byte](payload[lastIndex...index]))
                        statusInfo.append(value)
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
                        let value = String(cString: [Byte](invalidPayload[lastIndex...index]))
                        keyValueInfo.append(value)
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
                        let player = String(cString: [Byte](playerSection[lastIndex...index]))
                        playersInfo.append(player)
                        lastIndex = index + 1
                        if(lastIndex >= playerSection.count || playerSection[lastIndex] == 0x00) {
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
                    hostname: infoDict["hostname"] ?? "",
                    gameType: infoDict["gametype"] ?? "",
                    gameId: infoDict["game_id"] ?? "",
                    version: infoDict["version"] ?? "",
                    plugins: infoDict["plugins"] ?? "",
                    map: infoDict["map"] ?? "",
                    numplayers: infoDict["numplayers"] ?? "",
                    maxPlayers: infoDict["maxplayers"] ?? "",
                    hostPort: infoDict["hostport"] ?? "",
                    hostIP: infoDict["hostip"] ?? "",
                    players: playersInfo
                )
            }
            return nil
        }
    }
}
