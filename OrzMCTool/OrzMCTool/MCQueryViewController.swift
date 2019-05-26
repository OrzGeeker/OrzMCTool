//
//  MCQueryViewController.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/21.
//  Copyright © 2019 joker. All rights reserved.
//

import UIKit

class MCQueryViewController: UIViewController {

    @IBOutlet weak var serverListTableView: UITableView!
    
    var servers = [MCServerInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func addServer(_ sender: UIBarButtonItem) {
        
        let alertVC = UIAlertController(title: "查询Minecraft服务器", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "输入域名或IP地址"
            textField.keyboardType = .URL
            textField.keyboardAppearance = .dark
        }
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "输入端口号，默认为：\(MCQuery.defautlQueryPort)"
            textField.keyboardType = .numberPad
            textField.keyboardAppearance = .dark
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let fetchAction = UIAlertAction(title: "查询", style: .default) { (action) in
            if let textFields = alertVC.textFields, textFields.count == 2,
                let host = textFields[0].text {
                if let portStr = textFields[1].text, let port = Int32(portStr) {
                    self.checkServer(host, port: port)
                } else {
                    self.checkServer(host)
                }
            }
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(fetchAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func checkServer(_ host: String, port: Int32 = MCQuery.defautlQueryPort) {
        DispatchQueue.global().async {
            let query = MCQuery(host: host, port: port)
            query.handshake()
            if let fullStatus = query.fullStatus() {
                let serverInfo = MCServerInfo(host: host, port: port, statusInfo: fullStatus)
                if let index = self.servers.firstIndex(of: serverInfo) {
                    self.servers[index] = serverInfo
                } else {
                    self.servers.append(serverInfo)
                }
                DispatchQueue.main.async {
                    print(fullStatus)
                    self.serverListTableView.reloadData()
                }
            }  else {
                let alert = UIAlertController(title: "获取服务器状态失败", message: "请确认网络是否正常连接！", preferredStyle: .alert)
                let action = UIAlertAction(title: "确认", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
}

extension MCQueryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MCServerStatusCell.cellId, for: indexPath) as! MCServerStatusCell
        let server = self.servers[indexPath.row]
        let status = server.statusInfo
        cell.MOTD.attributedText = status.hostname.MODT
        cell.plugins.text = status.plugins
        cell.type.text = status.gameType
        cell.version.text = status.version
        cell.map.text = status.map
        cell.hostport.text = "\(server.host)(\(status.hostIP)):\(status.hostPort)"
        cell.playerInfo.text = "\(status.numplayers)/\(status.maxPlayers)"
        cell.players.text = status.players.joined(separator: ",")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servers.count
    }
}

extension MCQueryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let server = self.servers[indexPath.row]
        self.checkServer(server.host, port: server.port)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
