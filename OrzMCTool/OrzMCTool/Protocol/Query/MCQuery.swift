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
    
    struct Request {
        let magic = [0xFE, 0xFD]
        func data() -> Data {
            return Data()
        }
    }
    
    struct Response {
        init(_ data: Data) {
        }
    }
    
    static let BUFF_SIZE = 2048
    var host: String
    var port: Int32
    var client: UDPClient
    var token: Int32?
    
    init(host: String, port: Int32 = 25565) {
        self.host = host
        self.port = port
        self.client = UDPClient(address: self.host, port: self.port)
    }
    
    private func handshake() {
        let data = Data([0xFE, 0xFD, 0x09, 0x00, 0x00, 0x00, 0x01])
        switch self.client.send(data: data) {
        case .success:
            let (data, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let resp = data {
                if let tokenString = String(bytes: resp[5..<resp.count], encoding: .ascii) as NSString? {
                    self.token = tokenString.intValue
                }
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func basicStatus() {
        let data = Data([0xFE, 0xFD, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x91, 0x29, 0x5B])
        switch self.client.send(data: data) {
        case .success:
            let (data, _, _) = self.client.recv(MCQuery.BUFF_SIZE)
            if let resp = data {
                if let tokenString = String(bytes: resp[5..<resp.count], encoding: .ascii) as NSString? {
                    self.token = tokenString.intValue
                }
            } else {
                print("handshake failed!")
            }
        case .failure(let error):
            print(error.localizedDescription)
}
    }
    
    func fullStatus() {
        
    }
}
