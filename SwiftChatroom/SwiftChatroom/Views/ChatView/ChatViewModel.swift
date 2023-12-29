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
    
    var subscribers: Set<AnyCancellable> = []
    
    @Published var mockData = [
        Message(userId: "12345", text: "Test message!!!", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "Test 1111111", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "test test test ttt testttttt!", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "....", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "tEst?", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "ttt_test.", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "Test message!!!", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "Test 1111111", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "test test test ttt testttttt!", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "....", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "tEst?", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "ttt_test.", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "Test message!!!", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "Test 1111111", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "test test test ttt testttttt!", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "....", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "tEst?", photoUrl: "", createAt: Date()),
        Message(userId: "12345", text: "ttt_test.", photoUrl: "", createAt: Date()),
    ]
    
    init() {
        DatabaseManager.shared.fetchMessages() { [weak self] result in
            switch (result) {
            case .success(let msgs):
                self?.messages = msgs
            case .failure(let error):
                print(error)
            }
        }
        
        subscribeToMessagePublisher()
    }
    
    func sendMessage(text: String, completion: @escaping (Bool) -> Void) {
        guard let user = AuthManager.shared.getCurrentUser() else {
            return
        }
        let msg = Message(userId: user.uid, text: text, photoUrl: user.photoUrl, createAt: Date())
        DatabaseManager.shared.sendMessageToDatabase(message: msg) { [weak self] success in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func refresh() {
        self.messages = messages
    }
    
    private func subscribeToMessagePublisher() {
        DatabaseManager.shared.messagesPublisher.receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &subscribers)
    }
}
