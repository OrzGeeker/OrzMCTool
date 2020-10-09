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
                
                if let basicStatus = server?.basicStatus {
                    Text("\(basicStatus.MOTD)")
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
