//
//  OrzMCAdminApp.swift
//  OrzMCAdmin
//
//  Created by wangzhizhou on 2020/9/4.
//

import SwiftUI

@main
struct OrzMCAdminApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                OrzMCServerList().preferredColorScheme(.dark).environmentObject(MCDataStore())
            }
        }
    }
}

struct OrzMCAdminApp_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrzMCServerList()
        }
        .preferredColorScheme(.dark)
    }
}
