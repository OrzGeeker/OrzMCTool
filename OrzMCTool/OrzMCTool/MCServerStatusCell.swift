//
//  MCServerStatusCell.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/24.
//  Copyright © 2019 joker. All rights reserved.
//

import UIKit

class MCServerStatusCell: UITableViewCell {
    
    static let cellId = "serverStatusCell"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var MOTD: UILabel!
    @IBOutlet weak var ping: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var map: UILabel!
    @IBOutlet weak var playerInfo: UILabel!
    @IBOutlet weak var players: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var hostport: UILabel!
    @IBOutlet weak var plugins: UILabel!
    @IBOutlet weak var result: UILabel!
}

