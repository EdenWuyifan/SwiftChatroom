//
//  ContactRowView.swift
//  SwiftChatroom
//
//  Created by Yifan Wu on 2023/12/29.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContactRowView: View {
    
    let chat: Chat
    let pinned: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            
            // Photo
            if let photoUrl = chat.fetchPhotoUrl() {
                WebImage(url: photoUrl)
                    .resizable()
                    .frame(maxWidth: 72, maxHeight: 72)
                    .clipShape(Circle())
                    .padding(.leading, 27)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(maxWidth: 72, maxHeight: 72)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
            }
            
            // Text
            ZStack {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Name & Time
                        HStack {
                            Text(chat.otherUserName)
                 //               .font(
                                    
             //                       .system(size: 14).weight(.bold)
                  //              )
                                .font(
                                Font.custom("DM Sans", size: 14)
                                .weight(.medium)
                                )
                                .padding(.leading, 5)
                            
                            
                            Spacer()
                            //We don't have to show time on the main chat screen! Thanks!
//                            Text(chat.latestMessage?.lastestMessageTime.discriptiveString() ?? chat.createAt.discriptiveString())
//                                .font(
//                                    .system(size: 14).weight(.medium)
//                                )
                        }
                        .padding(.top, 32)
                        
                        // Latest Message
                        HStack {
                            Text(chat.latestMessage?.lastestMessageText ?? "")
                                //.font(.system(size: 14).weight(.medium))
                            
                                .font(Font.custom("DM Sans", size: 14))
                                .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                            
                            
                                .foregroundColor(!(chat.latestMessage?.isRead ?? false) ? Color(uiColor: .black) : Color(uiColor: .gray))
                                .lineLimit(1)
                                .frame(height: 50, alignment: .top)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 20)
                                .padding(.leading, 5)
                        }
                    }.layoutPriority(1.0)
                    if pinned {
                        Label("", systemImage: "staroflife.fill")
                            .foregroundColor(Color(uiColor: .systemYellow))
                            .frame(width: 18, height: 18)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .layoutPriority(0.5)
                            .padding(.trailing, 27)
                    }
                }
            }
        }
        .frame(maxHeight: 80)
    }
}

struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContactRowView(chat: Chat.testChat[0], pinned: true)
    }
}
