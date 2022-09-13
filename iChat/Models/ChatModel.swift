//
//  ChatModel.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import RealmSwift

class ChatModel: Object {
    @Persisted(primaryKey: true) var email: String?
    @Persisted var fullname: String?
    @Persisted var lastMessageDate: String?
    @Persisted var lastMessageText: String?
    @Persisted var username: String?
    @Persisted var unreadedMessagesCount: Int
    
    convenience init(
        email: String?,
        fullname: String?,
        lastMessageDate: String?,
        lastMessageText: String?,
        username: String?,
        unreadedMessagesCount: Int
    ) {
        self.init()
        self.email = email
        self.fullname = fullname
        self.lastMessageDate = lastMessageDate
        self.lastMessageText = lastMessageText
        self.username = username
        self.unreadedMessagesCount = unreadedMessagesCount
    }
}
