//
//  AuthManager.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/28.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift


struct ChatroomUser {
    let uid: String
    let name: String
    let email: String?
    let photoUrl: String?
}


enum GoogleSignInError: Error {
    case unableToGrabTopVC
    case signInPresentationError
    case authSignInError
}

final class AuthManager {
    
    static let shared = AuthManager()
    
    let auth = Auth.auth()
    
    func getCurrentUser() -> ChatroomUser? {
        guard let authUser = auth.currentUser else {
            return nil
        }
        
        return ChatroomUser(
            uid: authUser.uid,
            name: authUser.displayName ?? "Unknown",
            email: authUser.email,
            photoUrl: authUser.photoURL?.absoluteString
        )
    }
    
    func signInWithGoogle(completion: @escaping (Result<ChatroomUser, GoogleSignInError>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topVC = UIApplication.topViewController() else {
            completion(.failure(.unableToGrabTopVC))
            return
        }
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { [unowned self] result, error in
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  error == nil
            else {
                completion(.failure(.signInPresentationError))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            auth.signIn(with: credential) { result, err in
                guard let result = result,
                      error == nil
                else {
                    completion(.failure(.authSignInError))
                    return
                }
                
                let user = ChatroomUser(
                    uid: result.user.uid,
                    name: result.user.displayName ?? "Unknown",
                    email: result.user.email,
                    photoUrl: result.user.photoURL?.absoluteString
                )
                completion(.success(user))
            }
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
}



extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
