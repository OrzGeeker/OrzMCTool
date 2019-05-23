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

import Foundation
import SwiftSocket

class MCQuery {
    
    var host: String
    var port: Int32
    var client: UDPClient
    var token: Int32?
    var sessionID: Int32
    
    init(host: String, port: Int32 = 25565) {
        self.host = host
        self.port = port
        self.client = UDPClient(address: self.host, port: self.port)
        self.sessionID = 1
    }
    
    func handshake() {
        let handshakeRequest = Request(sessionID: self.sessionID)
        switch self.client.send(data: handshakeRequest.packet()) {
        case .success:
            let (data, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let resp = data {
                if let tokenString = String(bytes: resp[5..<resp.count], encoding: .ascii) as NSString? {
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
    
    func basicStatus() {
        
        guard let token = self.token else {
            print("Handshake failed!")
            return
        }
        
        let basicStatusRequest = Request(type: .status, sessionID: self.sessionID, payload: token.bigEndianBytes)
        switch self.client.send(data: basicStatusRequest.packet()) {
        case .success:
            let (data, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let resp = data {
                print(resp)
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
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
            let (data, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let resp = data {
                print(resp)
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    deinit {
        self.client.close()
    }
}

extension MCQuery {
    
    static let BUFF_SIZE = 4 * 1024
    
    struct Request {
        enum `Type`: Byte {
            case handshake = 0x09
            case status = 0x00
        }
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
            print(bytes)
            return bytes
        }
        
    }
    
    struct Response {
        init(_ data: Data) {
        }
    }
}
