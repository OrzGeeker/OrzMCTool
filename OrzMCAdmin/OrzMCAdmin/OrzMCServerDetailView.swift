//
//  OrzMCServerDetailView.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/16.
//

import SwiftUI

struct OrzMCServerDetailView: View {
    
    @State var rconCmd: String = ""
    
    var body: some View {
        VStack {
            OrzMCServerItem()
                .padding()
            
            HStack {
                Text("Query Info")
            }
            
            Spacer()
            
            VStack {
                Spacer()
                TextEditor(text: $rconCmd)
                    .foregroundColor(.white)
                Button(action: {
                    
                }, label: {
                    Text("Send RCON Command")
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
