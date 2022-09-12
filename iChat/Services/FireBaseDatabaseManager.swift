//
//  FireBaseDatabaseManager.swift
//  iChat
//
//  Created by Егор Шилов on 28.08.2022.
//

import FirebaseDatabase
import Foundation

class FireBaseDatabaseManager {
    static let shared = FireBaseDatabaseManager()
    
    var isPaginating = false
    
    var db = Database.database().reference()
    
    private func convertToCorrectEmail(email: String) -> String {
            var correctEmail = email.replacingOccurrences(of: ".", with: "-")
            correctEmail = correctEmail.replacingOccurrences(of: "@", with: "-")
            return correctEmail
    }
    
    func createUser(username: String, email: String, name: String, surname: String) {
        let correctEmail = convertToCorrectEmail(email: email)
        
        db.child("Users").child(correctEmail).setValue([
            "email": email,
            "name": name,
            "surname": surname,
            "username": username,
            "usernameForSearch": username.lowercased()
        ])
    }
    
    func getSelfUser(email: String, completion: @escaping (String, String) -> Void) {
        let correctSelfEmail = convertToCorrectEmail(email: email)
        
        db.child("Users/\(correctSelfEmail)").observeSingleEvent(of: .value) { data in
            guard data.exists() != false else { return }
            guard let value = data.value as? [String:Any] else { return }
            
            let name = value["name"] as? String
            let surname = value["surname"] as? String
            let username = value["username"] as? String
            let fullname = "\(name ?? "unknown") \(surname ?? "unknown")"
                        
            completion(fullname, username ?? "unknown")
        }
    }
    
    func searchUser(username: String, completion: @escaping ([UserModel]) -> Void) {
        let usernameLowered = username.lowercased()
        
        let query = db
            .child("Users")
            .queryOrdered(byChild: "usernameForSearch")
            .queryStarting(atValue: usernameLowered)
            .queryLimited(toFirst: 10)
        
        query.observeSingleEvent(of: .value) { (data) in
            guard data.exists() != false else { return }
            guard let value = data.value as? [String:[String:Any]] else { return }
            
            var users: [UserModel] = []
            
            value.forEach { (_, value: [String : Any]) in
                let emailValue = value["email"] as? String
                let nameValue = value["name"] as? String
                let surnameValue = value["surname"] as? String
                let usernameValue = value["username"] as? String
                let usernameForSearchValue = value["usernameForSearch"] as? String
                
                guard usernameForSearchValue?.contains(usernameLowered) == true else {return}
                
                let user = UserModel(
                    email: emailValue ?? "No email",
                    name: nameValue ?? "No name",
                    surname: surnameValue ?? "No surname",
                    username: usernameValue ?? "No username"
                )
                users.append(user)
            }
            completion(users)
        }
    }
    
    func sendMessage(to email: String, withName name: String, andUsername username: String, message: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: email)
                
        let dbSelfDestination = db
            .child("Conversations")
            .child(correctSelfEmail)
            .child("conversation-with-\(correctOtherEmail)")
        let dbOtherDestination = db
            .child("Conversations")
            .child(correctOtherEmail)
            .child("conversation-with-\(correctSelfEmail)")
        
        let specifiedDate = String(Date().timeIntervalSince1970)
        let messageID = specifiedDate.replacingOccurrences(of: ".", with: "-")
        
        // MARK: Send Messages To Database Conversations
        
        dbSelfDestination.child(messageID).setValue([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": true,
            "messageID": messageID
        ])
        
        dbOtherDestination.child(messageID).setValue([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": false,
            "messageID": messageID
        ])
        
        // MARK: Send last messages to users/USERID/listofconversations
        
        db.child("Users/\(correctSelfEmail)/listOfConversations/\(correctOtherEmail)").setValue([
                "email": correctOtherEmail,
                "fullName": name,
                "lastMessageDate": specifiedDate,
                "lastMessageText": message,
                "username": username
        ])
        
        db.child("Users/\(correctOtherEmail)/listOfConversations/\(correctSelfEmail)").updateChildValues([
                "email": correctSelfEmail,
                "fullName": UserLoginDataManager.shared.fullname ?? "unknown",
                "lastMessageDate": specifiedDate,
                "lastMessageText": message,
                "username": UserLoginDataManager.shared.username ?? "unknown"
        ])
        db.child("Users/\(correctOtherEmail)/listOfConversations/\(correctSelfEmail)/unreadedMessages").childByAutoId().setValue([
            "123": "123321"
        ])
    }
    
    func getMessages(withEmail otherEmail: String, andLimit limit: Int, completion: @escaping ([MessageModel]) -> Void) {
        self.isPaginating = true
        
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)
                
        self.db.child("Users/\(correctSelfEmail)/listOfConversations/\(correctOtherEmail)/unreadedMessages").removeValue()
        
        let query = db
            .child("Conversations")
            .child(correctSelfEmail)
            .child("conversation-with-\(correctOtherEmail)")
            .queryLimited(toLast: UInt(limit))
        
        query.observe(.value) { data in
            guard data.exists() != false else { return }
            guard let value = data.value as? [String:[String:Any]] else { return }
            
            var messages = [MessageModel]()
            
            value.forEach { (_, value: [String : Any]) in
                let messageTextValue = value["messageText"] as? String
                let dateValue = value["date"] as? String
                let isReadValue = value["isRead"] as? Bool
                let selfSenderValue = value["selfSender"] as? Bool
                let messageValue = value["messageID"] as? String
                
                let message = MessageModel(
                    messageText: messageTextValue ?? "No message information",
                    date: dateValue ?? "No date",
                    isRead: isReadValue ?? false,
                    selfSender: selfSenderValue ?? false,
                    messageID: messageValue ?? ""
                )
                
                messages.append(message)
            }
            let sortedMessages = messages.sorted(by: {$0.date < $1.date})
            completion(sortedMessages)
            
            self.isPaginating = false
        }
    }
    
    func getChats(completion: @escaping ([ChatModel]) -> Void ) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        
        let query = db.child("Users/\(correctSelfEmail)/listOfConversations").queryLimited(toFirst: 25)
        
        query.observe(.value) { data in
            guard data.exists() != false else { return }
            guard let chatsValues = data.value as? [String:[String:Any]] else { return }
            
            var chats = [ChatModel]()
            
            chatsValues.forEach { (_, value: [String : Any]) in
                let usernameValue = value["username"] as? String
                let fullnameValue = value["fullName"] as? String
                let emailValue = value["email"] as? String
                let lastMessageTextValue = value["lastMessageText"] as? String
                let lastMessageDateValue = value["lastMessageDate"] as? String
                
                let unreadedMessagesValue = value["unreadedMessages"] as? [String:Any]
                let unreadedMessagesCount = unreadedMessagesValue?.count
                
                let chat = ChatModel(
                    email: emailValue,
                    fullname: fullnameValue,
                    lastMessageDate: lastMessageDateValue,
                    lastMessageText: lastMessageTextValue,
                    username: usernameValue,
                    unreadedMessagesCount: unreadedMessagesCount ?? 0
                )
                
                chats.append(chat)
            }
            
            let sortedChats = chats.sorted(by: { Double($0.lastMessageDate ?? "0")! > Double($1.lastMessageDate ?? "0")! })
            completion(sortedChats)
        }
    }
    
    func deleteMessageForYourself(messageID: String, otherEmail: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)
        
        db.child("Conversations/\(correctSelfEmail)/conversation-with-\(correctOtherEmail)/\(messageID)").removeValue()
    }
    
    func deleteMessageForAll(messageID: String, otherEmail: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)
        
        db.child("Conversations/\(correctSelfEmail)/conversation-with-\(correctOtherEmail)/\(messageID)").removeValue()
        db.child("Conversations/\(correctOtherEmail)/conversation-with-\(correctSelfEmail)/\(messageID)").removeValue()
    }
    
    func updateUserImagePath(path: String?) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        
        db.child("Users/\(correctSelfEmail)/imagePath").setValue(path)
    }
    
    func removeConversationsObserver(with email: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: email)
        
        db.child("Conversations").child(correctSelfEmail).child("conversation-with-\(correctOtherEmail)").removeAllObservers()
    }
}
