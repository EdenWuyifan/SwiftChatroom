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
            case .failure(let error):
                print(error)
            }
        }
    }
}
