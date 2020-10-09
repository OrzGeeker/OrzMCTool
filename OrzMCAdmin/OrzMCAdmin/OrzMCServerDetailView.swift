//
//  OrzMCServerDetailView.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/16.
//

import SwiftUI

struct OrzMCServerDetailView: View {
    
    @State var server: MCServerInfo?
    @State var rconCmd: String = ""
    
    var body: some View {
        VStack {
            OrzMCServerItem(server: server)
                .padding()

            Spacer()
            
            VStack {
                Spacer()
                TextEditor(text: $rconCmd)
                    .foregroundColor(.white)
                Button(action: {
                    
                }, label: {
                    Text("Send RCON Command")
                        .bold()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                })
            }
        }
    }
}

struct OrzMCServerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        OrzMCServerDetailView()
            .preferredColorScheme(.dark)
    }
}
