//
//  OrzMCServerList.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/4.
//

import SwiftUI

struct OrzMCServerList: View {
    
    @EnvironmentObject private var store: MCDataStore
    
    @State var presented = false
    var body: some View {
        VStack {
            if store.servers.count > 0 {
                List {
                    ForEach(store.servers) { (server) in
                        NavigationLink(destination: OrzMCServerDetailView()) {
                            OrzMCServerItem(server: server)
                        }
                    }
                }
            } else {
                Text("暂无服务器信息")
            }
        }
        .padding()
        .sheet(isPresented: $presented, content: {
            OrzMCServerInfoView()
        })
        .navigationBarItems(trailing: Button("+", action: {
            self.presented.toggle()
        }))
        .navigationTitle("Minecraft Server")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OrzMCServerList()
    }
}
