//
//  ChatViewModel.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/28.
//

import Combine
import Foundation

class ChatViewModel: ObservableObject {
    
    @Published var messages = [Message]()
    @Published var chat: Chat
    
    init(chat: Chat, messages: [Message]) {
        self.chat = chat
        self.messages = messages
    }
    
    func sendMessage(text: String, completion: @escaping (Bool) -> Void) {
        guard let user = AuthManager.shared.getCurrentUser() else {
            return
        }
        let msg = Message(chatId: self.chat.chatId, userId: user.uid, text: text, photoUrl: user.photoUrl, createAt: Date())
        
        // Update chat
        updateLatestMessage(message: msg)
        DatabaseManager.shared.sendChatToDatabase(chat: chat) { [weak self] success in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        DatabaseManager.shared.sendMessageToDatabase(message: msg) { [weak self] success in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateLatestMessage(message: Message) {
        chat.latestMessage = LatestMessage(
            lastestMessageTime: message.createAt,
            lastestMessageText: message.text,
            isRead: false
        )
    }
    
    func markChatAsRead() {
        chat.latestMessage?.isRead = true
    }
    
    func refresh() {
        self.messages = messages
    }
}


extension ChatViewModel {
    static let mockData = ChatViewModel(
        chat: Chat(chatId: "1",
                   createAt: Date(),
                   otherUserId: "23456",
                   otherUserName: "Kim Bo",
                   otherUserPhotoUrl: "https://asianwiki.com/images/3/34/Bo-sung_Kim.jpg",
                   latestMessage: LatestMessage(
                    lastestMessageTime: Date(),
                    lastestMessageText: "This is Kim, please reply to me immediately! Hihihihihihihihihihihihihihihi~~",
                    isRead: false
                   )
                  ),
        messages: [
            Message(chatId: "1", userId: "12345", text: "Test message!!!", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "Test 1111111", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "test test test ttt testttttt!", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "....", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "tEst?", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "ttt_test.", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "Test message!!!", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "Test 1111111", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "test test test ttt testttttt!", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "....", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "tEst?", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "ttt_test.", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "Test message!!!", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "Test 1111111", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "test test test ttt testttttt!", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "....", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "tEst?", photoUrl: "", createAt: Date()),
            Message(chatId: "1", userId: "12345", text: "ttt_test.", photoUrl: "", createAt: Date()),
        ])
}
