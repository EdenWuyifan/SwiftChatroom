//
//  SignInView.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/28.
//

import SwiftUI

struct SignInView: View {
    @Binding var showSignIn: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            
            Image("forest1")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 500, maxHeight: 500, alignment: .top)
                .clipped()
//            Spacer()
            
            Text("You haven't signed in yet")
                .font(.largeTitle)
                .frame(maxWidth: 300)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 10) {
                Button {
                    print("Apple")
                } label: {
                    Text("Sign in with Apple")
                        .padding()
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke()
                                .foregroundColor(.primary)
                                .frame(width: 300)
                        )
                }
                Button {
                    AuthManager.shared.signInWithGoogle { result in
                        switch (result) {
                        case .success(_):
                            showSignIn = false
                        case .failure(let error):
                            print(error)
                        }
                    }
                } label: {
                    Text("Sign in with Google")
                        .padding()
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke()
                                .foregroundColor(.primary)
                                .frame(width: 300)
                        )
                }
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(showSignIn: .constant(true))
    }
}
