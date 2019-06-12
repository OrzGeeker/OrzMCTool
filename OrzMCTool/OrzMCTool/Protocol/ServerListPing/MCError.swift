//
//  MCError.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/10.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

enum MCError: Error {
    
    case VarIntTooBig
    // tcp connection
    case connectFailed(Error?)
    // handshake
    case handshakeFailed(Error?)
    // check status
    case checkStatusTimeout
    case checkStatusFailed(Error?)
    //  ping
    case pingTimeout
    case pingFailed(Error?)
    
}
