//
//  MCServerListViewController.swift
//  OrzMCTool
//
//  Created by joker on 2019/5/21.
//  Copyright © 2019 joker. All rights reserved.
//

import UIKit

class MCServerListViewController: UIViewController {

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
            textField.placeholder = "服务端口号，默认为：\(MCSLP.defaultPort)"
            textField.keyboardType = .numberPad
            textField.keyboardAppearance = .dark
        }
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "Query端口号，默认为：\(MCQuery.defaultQueryPort)"
            textField.keyboardType = .numberPad
            textField.keyboardAppearance = .dark
        }
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "RCON端口号，默认为：\(MCRCON.defaultRCONPort)"
            textField.keyboardType = .numberPad
            textField.keyboardAppearance = .dark
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let fetchAction = UIAlertAction(title: "查询", style: .default) { (action) in
            if  let textFields = alertVC.textFields, textFields.count == 4,
                let host = textFields[0].text {
                
                var port = MCSLP.defaultPort
                var queryPort = MCQuery.defaultQueryPort
                var rconPort = MCRCON.defaultRCONPort
                
                if  let inputPortStr = textFields[1].text,
                    let inputPort = Int32(inputPortStr) {
                    port = inputPort
                }
                
                if  let inputQueryPortStr = textFields[2].text,
                    let inputQueryPort = Int32(inputQueryPortStr) {
                    queryPort = inputQueryPort
                }
                
                if  let inputRCONPortStr = textFields[3].text,
                    let inputRCONPort = Int32(inputRCONPortStr) {
                    rconPort = inputRCONPort
                }
            
                self.checkServer(host, port: port, queryPort: queryPort, rconPort: rconPort)
            }
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(fetchAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func sendCmdLongGesture(_ sender: UILongPressGestureRecognizer) {
        if  sender.state == .began,
            let tableView = self.serverListTableView, let cell = sender.view as? MCServerStatusCell,
            let indexPath = tableView.indexPath(for: cell) {
            var server = self.servers[indexPath.row]
            server.rconCmdResult = nil
            self.sendRCONCmd(server.host, port: server.port, queryPort: server.queryPort, rconPort: server.rconPort, indexPath: indexPath)
        }
    }
    
    func sendRCONCmd(_ host: String, port: Int32, queryPort: Int32, rconPort: Int32, indexPath: IndexPath) {
        
        print("Send RCON Cmd!")
        
        let alertVC = UIAlertController(title: "\(host):\(rconPort)", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "输入RCON密码"
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.keyboardAppearance = .dark
            textField.returnKeyType = .next
        }
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "输入指令"
            textField.keyboardType = .default
            textField.keyboardAppearance = .dark
            textField.returnKeyType = .send
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let fetchAction = UIAlertAction(title: "发送", style: .default) { (action) in
            if  let textFields = alertVC.textFields, textFields.count == 2,
                let password = textFields[0].text,
                let cmdStr = textFields[1].text {
                DispatchQueue.global().async {
                    do {
                        let result = try MCRCON(host: host, port: rconPort).loginAndSendCmd(password: password, cmd: cmdStr)
                        var server = self.servers[indexPath.row]
                        server.rconCmdResult = "$ \(cmdStr)\n\(result ?? "")"
                        self.servers[indexPath.row] = server
                        DispatchQueue.main.async {
                            self.serverListTableView.reloadData()
                        }
                    } catch let e {
                        self.processException(e)
                    }
                }
            }
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(fetchAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func checkServer(_ host: String, port: Int32, queryPort: Int32, rconPort: Int32) {
        checkWithSLP(host, port: port, queryPort: queryPort, rconPort: rconPort)
        checkWithQuery(host, port: port, queryPort: queryPort, rconPort: rconPort)
    }
    
    func  checkWithSLP(_ host: String, port: Int32, queryPort: Int32, rconPort: Int32) {
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
                    
                    var serverInfo = MCServerInfo(host: host, port: port, queryPort: queryPort, rconPort: rconPort)
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
    
    func checkWithQuery(_ host: String, port: Int32, queryPort: Int32, rconPort: Int32) {
        DispatchQueue.global().async {
            let query = MCQuery(host: host, port: port)
            query.handshake()
            if let fullStatus = query.fullStatus() {
                var serverInfo = MCServerInfo(host: host, port: port, queryPort: queryPort, rconPort: rconPort)
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
        print(e)
    }
}

// MARK: DataSource Delegate

extension MCServerListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MCServerStatusCell.cellId, for: indexPath) as! MCServerStatusCell
        let server = self.servers[indexPath.row]
        cell.result.text = server.rconCmdResult?.MODT?.string
        
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

// MARK: TableViewDelegate
extension MCServerListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let server = self.servers[indexPath.row]
        self.checkServer(server.host, port: server.port, queryPort: server.queryPort, rconPort: server.rconPort)
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
