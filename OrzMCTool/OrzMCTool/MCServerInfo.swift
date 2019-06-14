//
//  MCServerInfo.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/24.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

struct MCServerInfo: Equatable {
    
    let host: String
    let port: Int32
    let queryPort: Int32
    let rconPort: Int32
    
    var statusInfo: MCServerStatusInfo
    var rconCmdResult: String?
    
    init(host: String, port: Int32, queryPort: Int32, rconPort: Int32, statusInfo: MCServerStatusInfo = MCServerStatusInfo()) {
        self.host = host
        self.port = port
        self.queryPort = queryPort
        self.rconPort = rconPort
        self.statusInfo = statusInfo
    }
    
    static func == (lhs: MCServerInfo, rhs: MCServerInfo) -> Bool {
        return lhs.host == rhs.host && lhs.port == rhs.port
    }
}
