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
        serverListTableView.estimatedRowHeight = 200
    }
    
    @IBAction func addServer(_ sender: UIBarButtonItem) {
        
        let alertVC = UIAlertController(title: "查询Minecraft服务器", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "输入域名或IP地址"
            textField.keyboardType = .URL
            textField.keyboardAppearance = .dark
        }
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "输入端口号，默认为：\(MCQuery.defaultQueryPort)"
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
    
    func checkServer(_ host: String, port: Int32 = MCQuery.defaultQueryPort) {
        checkWithSLP(host, port: port)
        checkWithQuery(host, port: port)
    }
    
    func  checkWithSLP(_ host: String, port: Int32) {
        DispatchQueue.global().async {
            let slp = MCSLP(host: host, port: port)
            do {
                try slp.handshake()
            } catch let e {
                self.processException(e)
            }
            
            do {
                let (status, ping) = try slp.status()
                if  let jsonData = status?.data(using: .utf8) {
                    let jsonDecoder = JSONDecoder()
                    let status = try jsonDecoder.decode(MCSLPStatus.self, from: jsonData)
                    
                    var serverInfo = MCServerInfo(host: host, port: port)
                    serverInfo.statusInfo.slpServerStatus = status
                    serverInfo.statusInfo.ping = ping
                    if let index = self.servers.firstIndex(of: serverInfo) {
                        self.servers[index].statusInfo.slpServerStatus = status
                        self.servers[index].statusInfo.ping = ping
                    } else {
                        self.servers.append(serverInfo)
                    }
                    DispatchQueue.main.async {
                        print(status)
                        print("\(ping) ms")
                        self.serverListTableView.reloadData()
                    }
                }
            } catch let e {
                self.processException(e)
            }
        }
    }
    
    func checkWithQuery(_ host: String, port: Int32) {
        DispatchQueue.global().async {
            let query = MCQuery(host: host, port: port)
            query.handshake()
            if let fullStatus = query.fullStatus() {
                var serverInfo = MCServerInfo(host: host, port: port)
                serverInfo.statusInfo.queryServerFullStatus = fullStatus
                if let index = self.servers.firstIndex(of: serverInfo) {
                    self.servers[index].statusInfo.queryServerFullStatus = fullStatus
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
    
    func processException(_ e: Error) {
        print(e.localizedDescription)
    }
}

extension MCQueryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MCServerStatusCell.cellId, for: indexPath) as! MCServerStatusCell
        let server = self.servers[indexPath.row]
        
        if let status = server.statusInfo.slpServerStatus,
            let imageData = status.favicon.base64EncodedImageData,
            let icon = UIImage(data: imageData) {
            cell.icon?.image = icon
            cell.MOTD.attributedText = status.description.text.MODT
            cell.playerInfo.text = "\(status.players.online)/\(status.players.max)"
        }
        
        if let ping = server.statusInfo.ping {
            cell.ping.text = "\(ping) ms"
            if ping <= 100 {
                cell.ping.textColor = .green
            } else if ping <= 100 {
                cell.ping.textColor = .yellow
            } else {
                cell.ping.textColor = .red
            }
        }
        
        if let status = server.statusInfo.queryServerFullStatus {
            cell.MOTD.attributedText = status.hostname.MODT
            cell.plugins.text = status.plugins
            cell.type.text = status.gameType
            cell.version.text = status.version
            cell.map.text = status.map
            cell.hostport.text = "\(server.host)(\(status.hostIP)):\(status.hostPort)"
            cell.playerInfo.text = "\(status.numplayers)/\(status.maxPlayers)"
            cell.players.text = status.players.joined(separator: ",")
        }
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.servers.remove(at: indexPath.row)
            tableView.reloadData()
        default:
            break
        }
    }
}
