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
                if let imageData = server?.slpStatus()?.favicon.base64EncodedImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64, alignment: .center)
                } else {
                    Image(systemName: "questionmark.square.dashed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64, alignment: .center)
                }
                VStack(alignment: .leading) {
                    if let name = server?.basicStatus?.MOTD.MODT?.string {
                        Text(name)
                    }
                    HStack {
                        if let version = server?.slpStatus()?.version {
                            Text("\(version.name)(\(version.protocol))")
                        }
                        
                        if let players = server?.slpStatus()?.players {
                            Text("\(players.online)/\(players.max)")
                        }
                    }
                }
                Spacer()
                if let pingMs = server?.pingMs {
                    Text("\(pingMs)ms")
                }
            }
        }
    }
}

struct OrzMCServerItem_Previews: PreviewProvider {
    static var previews: some View {
        OrzMCServerItem()
    }
}
