//
//  ContentView.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/28.
//

import SwiftUI

struct ContentView: View {
    
    @State var showSignIn: Bool
    
    init(showSignIn: Bool = true) {
        self.showSignIn = AuthManager.shared.getCurrentUser() == nil
    }
    
    var body: some View {
        
        
        if showSignIn {
            SignInView(showSignIn: $showSignIn)
        } else {
            NavigationStack {
                ZStack {
                    ContactView()
//                    ChatView(chat: Chat.testChat[0])
                }
                .navigationTitle("Chatroom")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        Button {
                            do {
                                try AuthManager.shared.signOut()
                                showSignIn = true
                            } catch {
                                print("Error signing out.")
                            }
                        } label: {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
