//
//  NewChatViewModel.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2024/1/4.
//

import Foundation

class NewChatViewModel: ObservableObject {
    
    @Published var chatroomUsers = [ChatroomUser]()
    
    init() {
        DatabaseManager.shared.fetchUsers() { [weak self] result in
            switch (result) {
            case .success(let users):
                self?.chatroomUsers = users
                print("Users", users)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func createNewChat(chatroomUser: ChatroomUser) -> Chat {
        let newChatId = UUID().uuidString
        let chat = Chat(chatId: newChatId, createAt: Date(), otherUserId: chatroomUser.uid, otherUserName: chatroomUser.name, otherUserPhotoUrl: chatroomUser.photoUrl ?? "Error", latestMessage: LatestMessage(lastestMessageTime: Date(), lastestMessageText: "", isRead: true))
        
        return chat
    }
}
