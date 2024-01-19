//
//  MainView.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2024/1/15.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContactView()
                .tabItem() {
                    Text("Search")
                }
            HostModeView()
                .tabItem() {
                    Text("Host")
                }
        }.frame(alignment: .top)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
