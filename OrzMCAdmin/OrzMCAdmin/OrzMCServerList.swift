//
//  OrzMCServerList.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/4.
//

import SwiftUI

struct OrzMCServerList: View {
    
    @EnvironmentObject private var store: MCDataStore
    
    var body: some View {
        VStack {
            if store.servers.count > 0 {
                List {
                    ForEach(store.servers) { (server) in
                        NavigationLink(destination: OrzMCServerDetailView(server: server)) {
                            OrzMCServerItem(server: server)
                        }
                    }
                }
            } else {
                VStack {
                    Text("暂无服务器信息")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    Text("可通过右上角\"+\"按钮进行添加")
                }
            }
        }
        .sheet(isPresented: $store.showServerInfoView, content: {
            OrzMCServerInfoView().preferredColorScheme(.dark)
                .environmentObject(store)
        })
        .navigationBarItems(trailing: Button(action: {
            store.showServerInfoView.toggle()
        }, label: {
            Image(systemName: "plus.circle")
                .imageScale(.large)
        }).frame(width: 44, height: 44, alignment: .center))
        .navigationTitle("Minecraft Server")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OrzMCServerList()
    }
}
