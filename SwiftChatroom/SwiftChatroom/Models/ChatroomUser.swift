//
//  ChatroomUser.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/29.
//

import Foundation

struct ChatroomUser: Identifiable {
    var id: String { uid }
    
    let uid: String
    let name: String
    let email: String?
    let photoUrl: String?
    
    func fetchPhotoUrl() -> URL? {
        guard let photoUrl = photoUrl, let url = URL(string: photoUrl) else {
            return nil
        }
        
        return url
    }
    
}
