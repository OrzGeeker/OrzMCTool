//
//  ContentView.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/4.
//

import SwiftUI

struct ContentView: View {
    @State var presented = false
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image("start")
                        .frame(width: 64, height: 64, alignment: .leading)
                        .border(Color.red, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    VStack(alignment: .leading) {
                        Text("Joker's Minecraft Server")
                        Text("jokerhub.cn")
                    }
                    Text("9ms")
                }
                Spacer()
            }
            .navigationBarItems(trailing: Button("+", action: {
                self.presented.toggle()
            }))
            .alert(isPresented: $presented, content: {
                Alert(title: Text("Server Info"))
            })
            .navigationTitle("Minecraft Server")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
