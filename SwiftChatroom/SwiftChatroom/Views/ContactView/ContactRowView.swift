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
    
    var body: some View {
        HStack(spacing: 10) {
            
            if let photoUrl = chat.fetchPhotoUrl() {
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
            
            ZStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(chat.otherUserName)
                            .font(
                                .system(size: 14).weight(.bold)
                            )
                        Spacer()
                        Text(chat.latestMessage?.lastestMessageTime.discriptiveString() ?? chat.createAt.discriptiveString())
                            .font(
                                .system(size: 14).weight(.medium)
                            )
                    }
                    .padding(.top, 32)
                    
                    HStack {
                        Text(chat.latestMessage?.lastestMessageText ?? "")
                            .font(.system(size: 14).weight(.medium))
                            .foregroundColor(!(chat.latestMessage?.isRead ?? false) ? Color(uiColor: .black) : Color(uiColor: .gray))
                            .lineLimit(1)
                            .frame(height: 50, alignment: .top)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 20)
                    }
                }
//                Circle()
//                    .foregroundColor(!(chat.latestMessage?.isRead ?? false) ? Color(uiColor: .systemBlue) : .clear)
//                    .frame(width: 18, height: 18)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
                
            }
        }
        .frame(maxHeight: 80)
    }
}

struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContactRowView(chat: Chat.testChat[0])
    }
}
