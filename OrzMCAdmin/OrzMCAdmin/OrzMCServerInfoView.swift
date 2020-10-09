//
//  OrzMCServerInfoView.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/30.
//

import SwiftUI
import OrzMCCore

struct OrzMCServerInfoView: View {
    
    @EnvironmentObject private var store: MCDataStore
    
    static private let defaultPort: Int32 = 25565
    
    @State private var host: String = ""
    @State private var slpPort: String = ""
    @State private var queryPort: String = ""
    @State private var rconPort: String = ""
    
    var body: some View {
        VStack {
            VStack {
                Text("查询Minecraft服务器")
                    .font(.headline)
                TextField("输入域名或IP地址", text: $host)
                    .keyboardType(.alphabet)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                TextField("SLP服务端口号，默认为:\(Self.defaultPort)", text: $slpPort)
                    .keyboardType(.numberPad)
                TextField("Query服务端口号，默认为:\(Self.defaultPort)", text: $queryPort)
                    .keyboardType(.numberPad)
                TextField("RCON服务端口号，默认为:\(Self.defaultPort)", text: $rconPort)
                    .keyboardType(.numberPad)
            }
            Button(action: {
                store.showServerInfoView.toggle()
            }, label: {
                Text("确定")
            })
        }
        .padding()
        .onDisappear(perform: {
            // 存放收集的服务器信息
            let slpPort = Int32(self.slpPort) ?? Self.defaultPort
            let queryPort = Int32(self.queryPort) ?? Self.defaultPort
            let rconPort = Int32(self.rconPort) ?? Self.defaultPort
            
            if self.host.count > 0 {
                let server = MCServerInfo(id: store.servers.count, host: self.host, slpPort: slpPort, queryPort: queryPort, rconPort: rconPort)
                store.servers.append(server)
            }
        })
        .onTapGesture(count: 1, perform: {
            UIApplication.shared.windows.first?.endEditing(true)
        })
    }
}

struct OrzMCServerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        OrzMCServerInfoView()
    }
}
