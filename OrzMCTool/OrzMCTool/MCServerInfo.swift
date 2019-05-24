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
    let statusInfo: MCServerFullStatus
    
    static func == (lhs: MCServerInfo, rhs: MCServerInfo) -> Bool {
        return lhs.host == rhs.host && lhs.port == rhs.port
    }
}
