//
//  ContactView.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/29.
//

import SwiftUI

struct ContactView: View {
    
    @StateObject var contactViewModel = ContactViewModel()
    @State private var query = ""
    
    @State var shouldNavigateToChatView = false
    @State var shouldShowNewMessageScreen = false
    @State var chatroomUser: ChatroomUser?
    
    
    var body: some View {
        NavigationView {
            VStack {
                chatListView
                
                
                NavigationLink("", isActive: $shouldNavigateToChatView) {
                    ChatView(chatViewModel: contactViewModel.createNewChatViewModel(chatroomUser: chatroomUser))
                }
            }
            .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                NewChatView(didSelectNewUser: { chatroomUser in
                    print(chatroomUser.name)
                    self.chatroomUser = chatroomUser
                    
                    self.shouldNavigateToChatView.toggle()
                })
            }
        }
    }
    
    private var chatListView: some View {
        List {
            ForEach(contactViewModel.getSortedFilteredChats(query: query)) { chat in
                //            ForEach(ContactViewModel.mockChat) { chat in
                ZStack {
                    ContactRowView(chat: chat)
                    
                    NavigationLink(destination: ChatView(
                        chatViewModel: (contactViewModel.chatViewModels.keys.contains(chat.chatId)) ? contactViewModel.chatViewModels[chat.chatId]!: ChatViewModel(chat: chat, messages: [Message]())
                    )) {
                        EmptyView()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 0)
                    .opacity(0)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Chats")
        .searchable(text: $query)
        .navigationBarItems(
            trailing:Button {
                shouldShowNewMessageScreen.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
            }
        )
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
