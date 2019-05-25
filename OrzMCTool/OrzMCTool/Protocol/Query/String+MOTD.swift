//
//  String+MOTD.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/24.
//  Copyright © 2019 joker. All rights reserved.
//

import Foundation

extension String {
    public var MODT: NSAttributedString? {
        let sectionChar: Character = "\u{00A7}"
        print(sectionChar)
        print(self[self.startIndex].unicodeScalars)
        for index in self.indices {
            if self[index] == sectionChar {
                
            }
        }
        
        return NSAttributedString(string: self)
    }
}
