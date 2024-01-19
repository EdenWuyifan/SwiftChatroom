//
//  DatabaseManager.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/28.
//

import Combine
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum DatabaseError: Error {
    case snapshotError
    case authFetchUserIdError
    case emptyQueryArrayError
}

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    let userRef = Firestore.firestore().collection("users")
    let messageRef = Firestore.firestore().collection("messages")
    
//    var chatroomUsersPublisher = PassthroughSubject<[ChatroomUser], Error>()
    var chatsPublisher = PassthroughSubject<[Chat], Error>()
    var messagesPublisher = PassthroughSubject<[Message], Error>()
    
    var messagesListener: ListenerRegistration? = nil
    
    func fetchUsers(completion: @escaping (Result<[ChatroomUser], DatabaseError>) -> Void) {
        userRef.limit(to: 10).getDocuments() { [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                completion(.failure(.snapshotError))
                return
            }
//            strongSelf.listenForNewUsersInDatabase()
            let users = strongSelf.createChatroomUsersFromFirebaseSnapshot(snapshot: snapshot)
            completion(.success(users))
        }
    }
    
    func fetchChats(completion: @escaping (Result<[Chat], DatabaseError>) -> Void) {
        guard let uid = AuthManager.shared.getCurrentUser()?.uid else {
            completion(.failure(.authFetchUserIdError))
            return
        }
        userRef.document(uid).collection("chats")
            .order(by: "createAt", descending: false)
            .limit(to: 10)
            .getDocuments() { [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                completion(.failure(.snapshotError))
                return
            }
            strongSelf.listenForNewChatsInDatabase()
            let chats = strongSelf.createChatsFromFirebaseSnapshot(snapshot: snapshot)
            completion(.success(chats))
        }
    }
    
    func fetchMessages(chatIds: [String], completion: @escaping (Result<[Message], DatabaseError>) -> Void) {
        if chatIds.count == 0 {
            completion(.failure(.emptyQueryArrayError))
            return
        }
        messageRef.whereField("chatId", in: chatIds)
            .order(by: "createAt", descending: false)
            .limit(to: 25)
            .getDocuments() { [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                completion(.failure(.snapshotError))
                return
            }
            
                strongSelf.listenForNewMessagesInDatabase(chatIds: chatIds)
            let messages = strongSelf.createMessagesFromFirebaseSnapshot(snapshot: snapshot)
            completion(.success(messages))
        }
    }
    
    func sendUserToDatabase(user: ChatroomUser, completion: @escaping (Bool) -> Void) {
        let data = [
            "uid": user.uid,
            "name":user.name,
            "email": user.email ?? "Error",
            "photoUrl": user.photoUrl ?? "Error"
        ] as [String: Any]
        
        userRef.document(user.uid).setData(data) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func sendChatToDatabase(chat: Chat, completion: @escaping (Bool) -> Void) {
        guard let user = AuthManager.shared.getCurrentUser() else {
            completion(false)
            return
        }
        
        // Chat for current user
        let data = [
            "chatId": chat.chatId,
            "createAt": Timestamp(date: chat.createAt),
            "otherUserId": chat.otherUserId,
            "otherUserName": chat.otherUserName,
            "otherUserPhotoUrl": chat.otherUserPhotoUrl ?? "Error",
            "lastestMessageTime": Timestamp(date: chat.latestMessage?.lastestMessageTime ?? chat.createAt),
            "lastestMessageText": chat.latestMessage?.lastestMessageText ?? "Error",
            "isRead": chat.latestMessage?.isRead ?? true,
            "unreadCounts": chat.latestMessage?.isRead ?? true ? 0 : 1
        ] as [String: Any]
        
        userRef.document(user.uid).collection("chats").document(chat.chatId).setData(data) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func sendChatToOtherUserDatabase(chat: Chat, completion: @escaping (Bool) -> Void) {
        guard let user = AuthManager.shared.getCurrentUser() else {
            completion(false)
            return
        }
        // Chat for other user
        let otherUserData = [
            "chatId": chat.chatId,
            "createAt": Timestamp(date: chat.createAt),
            "otherUserId": user.uid,
            "otherUserName": user.name,
            "otherUserPhotoUrl": user.photoUrl ?? "Error",
            "lastestMessageTime": Timestamp(date: chat.latestMessage?.lastestMessageTime ?? chat.createAt),
            "lastestMessageText": chat.latestMessage?.lastestMessageText ?? "Error",
            "isRead": false,
            "unreadCounts": chat.unreadCounts + 1
        ] as [String : Any]
        
        userRef.document(chat.otherUserId).collection("chats").document(chat.chatId).setData(otherUserData) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func sendMessageToDatabase(message: Message, completion: @escaping (Bool) -> Void) {
        let data = [
            "text": message.text,
            "chatId": message.chatId,
            "userId": message.userId,
            "photoUrl": message.photoUrl ?? "Error",
            "createAt": Timestamp(date: message.createAt)
        ] as [String: Any]
        
        messageRef.addDocument(data: data) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    func listenForNewChatsInDatabase() {
        guard let user = AuthManager.shared.getCurrentUser() else {
            return
        }
        userRef.document(user.uid).collection("chats")
            .order(by: "createAt", descending: false)
            .limit(to: 10)
            .addSnapshotListener{ [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                print("listenForNewChatsInDatabase: ", error)
                return
            }
            
            let chats = strongSelf.createChatsFromFirebaseSnapshot(snapshot: snapshot)
            strongSelf.chatsPublisher.send(chats)
        }
    }
    
    func listenForNewMessagesInDatabase(chatIds: [String]) {
        messagesListener?.remove()
        messagesListener = messageRef.whereField("chatId", in: chatIds)
            .order(by: "createAt", descending: false)
            .limit(to: 25)
            .addSnapshotListener{ [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                print("listenForNewMessagesInDatabase: ", error)
                return
            }
            
            let messages = strongSelf.createMessagesFromFirebaseSnapshot(snapshot: snapshot)
            strongSelf.messagesPublisher.send(messages)
        }
    }
    
    func createChatroomUsersFromFirebaseSnapshot(snapshot: QuerySnapshot) -> [ChatroomUser] {
        let docs = snapshot.documents
        
        var chatroomUsers = [ChatroomUser]()
        
        for doc in docs {
            let data = doc.data()
            let uid = data["uid"] as? String ?? "Error"
            let name = data["name"] as? String ?? "Error"
            let email = data["email"] as? String ?? "Error"
            let photoUrl = data["photoUrl"] as? String ?? "Error"
            
            let user = ChatroomUser(uid: uid, name: name, email: email, photoUrl: photoUrl)
            chatroomUsers.append(user)
        }
        
        return chatroomUsers
    }
    
    func createChatsFromFirebaseSnapshot(snapshot: QuerySnapshot) -> [Chat] {
        let docs = snapshot.documents
        
        var chats = [Chat]()
        
        for doc in docs {
            let data = doc.data()
            let chatId = data["chatId"] as? String ?? "Error"
            let createAt = data["createAt"] as? Timestamp ?? Timestamp()
            let otherUserId = data["otherUserId"] as? String ?? "Error"
            let otherUserName = data["otherUserName"] as? String ?? "Error"
            let otherUserPhotoUrl = data["otherUserPhotoUrl"] as? String ?? "Error"
            let lastestMessageTime = data["lastestMessageTime"] as? Timestamp ?? Timestamp()
            let lastestMessageText = data["lastestMessageText"] as? String ?? "Error"
            let isRead = data["isRead"] as? Bool ?? false
            let unreadCounts = data["unreadCounts"] as? Int ?? 0
            
            let chat = Chat(chatId: chatId, createAt: createAt.dateValue(), otherUserId: otherUserId, otherUserName: otherUserName, otherUserPhotoUrl: otherUserPhotoUrl, latestMessage: LatestMessage(lastestMessageTime: lastestMessageTime.dateValue(), lastestMessageText: lastestMessageText, isRead: isRead), unreadCounts: unreadCounts)
            chats.append(chat)
        }
        
        return chats
    }
    
    func createMessagesFromFirebaseSnapshot(snapshot: QuerySnapshot) -> [Message] {
        let docs = snapshot.documents
        
        var messages = [Message]()
        
        for doc in docs {
            let data = doc.data()
            let text = data["text"] as? String ?? "Error"
            let chatId = data["chatId"] as? String ?? "Error"
            let userId = data["userId"] as? String ?? "Error"
            let photoUrl = data["photoUrl"] as? String ?? "Error"
            let createAt = data["createAt"] as? Timestamp ?? Timestamp()
            
            let message = Message(chatId: chatId, userId: userId, text: text, photoUrl: photoUrl, createAt: createAt.dateValue())
            messages.append(message)
        }
        
        return messages
    }
                                                                            
}
