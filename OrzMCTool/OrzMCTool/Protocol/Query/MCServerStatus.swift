//
//  MCServerStatus.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/23.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

struct MCServerStatus {
    let MOTD: String
    let gameType: String
    let map: String
    let numplayers: String
    let maxplayers: String
    let hostport: Int16
    let hostip: String
}
