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
}

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    let messageRef = Firestore.firestore().collection("messages")
    
    var messagesPublisher = PassthroughSubject<[Message], Error>()
    
    func fetchMessages(completion: @escaping (Result<[Message], DatabaseError>) -> Void) {
        messageRef.order(by: "createAt", descending: false).limit(to: 25).getDocuments() { [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                completion(.failure(.snapshotError))
                return
            }
            
            strongSelf.listenForNewMessagesInDatabase()
            let messages = strongSelf.createMessagesFromFirebaseSnapshot(snapshot: snapshot)
            completion(.success(messages))
        }
    }
    
    func sendMessageToDatabase(message: Message, completion: @escaping (Bool) -> Void) {
        let data = [
            "text": message.text,
            "userId": message.userId,
            "photoUrl": message.photoUrl ?? "Error",
            "createAt": Timestamp(date: message.createAt)
        ] as [String: Any]
        
        let messageRef = messageRef.addDocument(data: data) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func listenForNewMessagesInDatabase() {
        messageRef.order(by: "createAt", descending: false).limit(to: 25).addSnapshotListener{ [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let strongSelf = self else {
                return
            }
            
            let messages = strongSelf.createMessagesFromFirebaseSnapshot(snapshot: snapshot)
            strongSelf.messagesPublisher.send(messages)
        }
    }
    
    func createMessagesFromFirebaseSnapshot(snapshot: QuerySnapshot) -> [Message] {
        let docs = snapshot.documents
        
        var messages = [Message]()
        
        for doc in docs {
            let data = doc.data()
            let text = data["text"] as? String ?? "Error"
            let userId = data["userId"] as? String ?? "Error"
            let photoUrl = data["photoUrl"] as? String ?? "Error"
            let createAt = data["createAt"] as? Timestamp ?? Timestamp()
            
            let message = Message(userId: userId, text: text, photoUrl: photoUrl, createAt: createAt.dateValue())
            messages.append(message)
        }
        
        return messages
    }
                                                                            
}
