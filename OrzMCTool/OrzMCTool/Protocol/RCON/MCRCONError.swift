//
//  MCRCONError.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/14.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

enum MCRCONError: Error {
    case connectFailed(Error?)
    case sendCmdFailed(Error?)
    case authTimeout
    case packetMalFormat
    case authFailed
    case sendCmdTimeout
    case responseInvalid
}
