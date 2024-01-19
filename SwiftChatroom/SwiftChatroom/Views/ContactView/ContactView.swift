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
    @State var shouldBeInHostMode = false
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
                let chatView = ChatView(
                    chatViewModel: (contactViewModel.chatViewModels.keys.contains(chat.chatId)) ? contactViewModel.chatViewModels[chat.chatId]!: ChatViewModel(chat: chat, messages: [Message]())
                )
                ZStack {
                    ContactRowView(chat: chat)
                    
                    NavigationLink(destination: chatView.onAppear {
                        chatView.chatViewModel.markChatAsRead(newValue: true)
                    }) {
                        EmptyView()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 0)
                    .opacity(0)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(action: {
                        chatView.chatViewModel.markChatAsRead(newValue: !chat.latestMessage!.isRead)
                    }, label: {
                        if !chat.latestMessage!.isRead {
                            Label("Read", systemImage: "text.bubble")
                        } else {
                            Label("Unread", systemImage: "circle.fill")
                        }
                    })
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Message")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query)
        .toolbarBackground(Color(red: 1, green: 0.77, blue: 0.18), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
