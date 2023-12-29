//
//  Message.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/28.
//

import Foundation


struct Message: Decodable, Identifiable, Equatable, Hashable {
    var id = UUID()
    
    let userId: String
    let text: String
    let photoUrl: String?
    let createAt: Date
    
    func isSender() -> Bool {
        guard let currUser = AuthManager.shared.getCurrentUser() else {
            return false
        }
        if currUser.uid == userId {
            return true
        }
        return false
    }
    
    func fetchPhotoUrl() -> URL? {
        guard let photoUrl = photoUrl, let url = URL(string: photoUrl) else {
            return nil
        }
        
        return url
    }
}
