//
//  MCSLPError.swift
//  OrzMCTool
//
//  Created by joker on 2019/6/10.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

enum MCSLPError: Error {
    
    case socketCreateFailed
    case VarIntTooBig
    case pingFailed
    
}
