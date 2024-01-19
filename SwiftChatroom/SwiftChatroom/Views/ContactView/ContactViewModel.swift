//
//  ContactViewModel.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/29.
//

import Combine
import Foundation

class ContactViewModel: ObservableObject {
    
    @Published var chats = [Chat]()
    @Published var chatViewModels = [String: ChatViewModel]()
    @Published var messages = [Message]()
    @Published var pinnedChats: Set<String> = [] // Stores the chatIds of pinned chats
    
    var chatSubscribers: Set<AnyCancellable> = []
    var messageSubscribers: Set<AnyCancellable> = []
    
    init() {
        DatabaseManager.shared.fetchChats() { [weak self] result in
            switch (result) {
            case .success(let chats):
                self?.chats = chats
            case .failure(let error):
                print(error)
            }
        }
        
        subscribeToChatPublisher()
        subscribeToMessagePublisher()
    }
    
    private func subscribeToChatPublisher() {
        DatabaseManager.shared.chatsPublisher.receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] chats in
                self?.chats = chats
                self?.refreshMessagesSubscriber()
                self?.generateChatViewModels()
            }
            .store(in: &chatSubscribers)
    }
    
    private func subscribeToMessagePublisher() {
        DatabaseManager.shared.messagesPublisher.receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &messageSubscribers)
    }
    
    func getSortedFilteredChats(query: String) -> [Chat] {
        var sortedChats = chats.sorted {
            guard let date1 = $0.latestMessage?.lastestMessageTime as Date? else { return false }
            guard let date2 = $1.latestMessage?.lastestMessageTime as Date? else { return false }
            return date1 > date2
        }
        
        // Pinned
        sortedChats = chats.sorted { (a, b) -> Bool in
            return pinnedChats.contains(a.chatId)
        }
        
        if query == "" {
            return sortedChats
        }
        return sortedChats.filter{ $0.otherUserName.lowercased().contains(query.lowercased()) }
    }
    
    func updateChatPin(chatId: String) {
        if pinnedChats.contains(chatId) {
            pinnedChats.remove(chatId)
        } else {
            pinnedChats.insert(chatId)
        }
    }
    
    
    func refreshMessagesSubscriber() {
        var chatIds = [String]()
        for chat in self.chats {
            chatIds.append(chat.chatId)
        }
//        print("ChatIds", chatIds)
        
        DatabaseManager.shared.fetchMessages(chatIds: chatIds) { [weak self] result in
            switch (result) {
            case .success(let messages):
                self?.messages = messages
                self?.generateChatViewModels()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func generateChatViewModels() {
        for chat in self.chats {
            let chatViewModel = ChatViewModel(chat: chat, messages: fetchChatMessages(chatId: chat.chatId))
            chatViewModels[chat.chatId] = chatViewModel
        }
    }
    
    func createNewChatViewModel(chatroomUser: ChatroomUser?) -> ChatViewModel {
        var tempUser: ChatroomUser = chatroomUser ?? ChatroomUser(uid: "0", name: "Error", email: "Error", photoUrl: "Error")
        for (_, chatViewModel) in chatViewModels {
            if chatViewModel.chat.otherUserId == tempUser.uid {
                return chatViewModel
            }
        }
        let newChatId = UUID().uuidString
        var chat = Chat(chatId: newChatId, createAt: Date(), otherUserId: tempUser.uid, otherUserName: tempUser.name, otherUserPhotoUrl: tempUser.photoUrl ?? "Error", latestMessage: LatestMessage(lastestMessageTime: Date(), lastestMessageText: "", isRead: true), unreadCounts: 0)
        return ChatViewModel(chat: chat, messages: [Message]())
    }
    
    func fetchChatMessages(chatId: String) -> [Message] {
        let messages = messages.filter { message in
            if message.chatId == chatId {
                return true
            } else {
                return false
            }
        }
        return messages
    }
}


extension ContactViewModel {
    static var mockChat = [
        Chat(chatId: "1",
             createAt: Date(),
             otherUserId: "23456",
             otherUserName: "Kim Bo",
             otherUserPhotoUrl: "https://asianwiki.com/images/3/34/Bo-sung_Kim.jpg",
             latestMessage: LatestMessage(
                lastestMessageTime: Date(),
                lastestMessageText: "This is Kim, please reply to me immediately! Hihihihihihihihihihihihihihihi~~",
                isRead: false
             ),
             unreadCounts: 2
        ),
        Chat(chatId: "2",
             createAt: Date(),
             otherUserId: "34567",
             otherUserName: "Eden Wu",
             otherUserPhotoUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTn8_j8xxqBXGCwr1do3aGbOi7kBnRYJjTUYg&usqp=CAU",
             latestMessage: LatestMessage(
                lastestMessageTime: Date(),
                lastestMessageText: "Okayyyy :)",
                isRead: true
             ),
             unreadCounts: 0
        )
    ]
    
    static var mockContactViewModel = ContactViewModel()
}
