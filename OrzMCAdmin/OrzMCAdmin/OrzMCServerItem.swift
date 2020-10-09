//
//  OrzMCServerItem.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/17.
//

import SwiftUI

struct OrzMCServerItem: View {
    
    @State var server: MCServerInfo?
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "questionmark.square.dashed")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64, alignment: .center)
                VStack(alignment: .leading) {
                    Text("Joker's Minecraft Server")
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                    Text("jokerhub.cn")
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                }
                
                Spacer()
                
                Text("9ms")
            }
        }
    }
}

struct OrzMCServerItem_Previews: PreviewProvider {
    static var previews: some View {
        OrzMCServerItem()
    }
}
