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
//              ForEach(ContactViewModel.mockChat) { chat in
                let chatView = ChatView(
                    chatViewModel: (contactViewModel.chatViewModels.keys.contains(chat.chatId)) ? contactViewModel.chatViewModels[chat.chatId]!: ChatViewModel(chat: chat, messages: [Message]())
                )
                ZStack {
                    ContactRowView(chat: chat, pinned: contactViewModel.pinnedChats.contains(chat.chatId))
                    
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
                            Label("Read", systemImage: "text.bubble.fill")
                        } else {
                            Label("Unread", systemImage: "circle.fill")
                        }
                    }).tint(
                        !chat.latestMessage!.isRead ? Color(uiColor: .systemGray) : Color(uiColor: .systemBlue))
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    
                    Button(action: {
                        chatView.chatViewModel.markChatAsRead(newValue: !chat.latestMessage!.isRead)
                    }, label: {
                        Label("Delete", systemImage: "xmark.bin.fill")
                    }).tint(Color(uiColor: .systemRed))
                    
                    Button(action: {
                        contactViewModel.updateChatPin(chatId: chat.chatId)
                    }, label: {
                        if contactViewModel.pinnedChats.contains(chat.chatId) {
                            Label("Unpin", systemImage: "pin.slash.fill")
                        } else {
                            Label("Pin", systemImage: "pin.fill")
                        }
                    }).tint(contactViewModel.pinnedChats.contains(chat.chatId) ? Color(uiColor: .systemGray) : Color(red: 1, green: 0.77, blue: 0.18))
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
