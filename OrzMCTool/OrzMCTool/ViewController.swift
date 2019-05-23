//
//  ViewController.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/21.
//  Copyright © 2019 joker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let query = MCQuery(host: "jokerhub.cn")
        query.handshake()
    }


}

