//
//  NewChatView.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2024/1/3.
//

import SwiftUI
import SDWebImageSwiftUI


struct NewChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var newChatViewModel = NewChatViewModel()
    @State private var query = ""
    
    let didSelectNewUser: (ChatroomUser) -> ()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(newChatViewModel.chatroomUsers) { chatroomUser in
                    Button {
                        didSelectNewUser(chatroomUser)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            if let photoUrl = chatroomUser.fetchPhotoUrl() {
                                WebImage(url: photoUrl)
                                    .resizable()
                                    .frame(maxWidth: 70, maxHeight: 70)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(maxWidth: 70, maxHeight: 70)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(chatroomUser.name).bold()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button{
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .searchable(text: $query)
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
