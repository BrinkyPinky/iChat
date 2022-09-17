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
    
    // MARK: User Interactions
    
    func checkIfUserNameIsFree(username: String, completion: @escaping (Bool) -> Void) {
        let usernameForSearch = username.lowercased()
        
        let query = db
            .child("Users")
            .queryOrdered(byChild: "usernameForSearch")
            .queryEqual(toValue: usernameForSearch)
            .queryLimited(toFirst: 1)
        
        query.observeSingleEvent(of: .value) { Data in
            guard Data.exists() else {
                completion(true)
                return
            }
            completion(false)
        }
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
    
    func changeUserInformation(username: String, name: String, surname: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        
        db.child("Users/\(correctSelfEmail)").updateChildValues([
            "name": name,
            "surname": surname,
            "username": username,
            "usernameForSearch": username.lowercased()
        ])
    }
    
    // MARK: Messages Interactions
    
    func sendMessage(to email: String, withName name: String, andUsername username: String, message: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: email)
        
        let specifiedDate = String(Date().timeIntervalSince1970)
        let messageID = specifiedDate.replacingOccurrences(of: ".", with: "-")
        
        // MARK: Self Database Desination
        
        let dbSelfDestination = db
            .child("Conversations")
            .child(correctSelfEmail)
            .child("conversation-with-\(correctOtherEmail)")
        let dbSelfChatsDestination = db
            .child("Chats/\(correctSelfEmail)/\(correctOtherEmail)")
        
        dbSelfDestination.child(messageID).setValue([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": true,
            "messageID": messageID
        ])
        dbSelfChatsDestination.setValue([
            "lastMessageDate": specifiedDate,
            "lastMessageText": message
        ])
        
        guard correctSelfEmail != correctOtherEmail else {
            dbSelfDestination.child(messageID).child("isRead").setValue(true)
            return
        }
        
        // MARK: Other Database Desination
        
        let dbOtherDestination = db
            .child("Conversations")
            .child(correctOtherEmail)
            .child("conversation-with-\(correctSelfEmail)")
        let dbOtherChatsDestination = db
        .child("Chats/\(correctOtherEmail)/\(correctSelfEmail)")
        
        dbOtherDestination.child(messageID).setValue([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": false,
            "messageID": messageID
        ])
        dbOtherChatsDestination.setValue([
            "lastMessageDate": specifiedDate,
            "lastMessageText": message
        ])
    }
    
    func getMessages(withEmail otherEmail: String, andLimit limit: Int, completion: @escaping ([MessageModel]) -> Void) {
        self.isPaginating = true
        
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)
        
        let query = db
            .child("Conversations")
            .child(correctSelfEmail)
            .child("conversation-with-\(correctOtherEmail)")
            .queryLimited(toLast: UInt(limit))
        
        query.observe(.value) { data in
            guard data.exists() != false else {
                self.isPaginating = false
                return
            }
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
    
    func readMessage(messageID: String, otherEmail: String) {
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        
        db.child("Conversations/\(correctOtherEmail)/conversation-with-\(correctSelfEmail)/\(messageID)/isRead").setValue(true)
        db.child("Conversations/\(correctSelfEmail)/conversation-with-\(correctOtherEmail)/\(messageID)/isRead").setValue(true)
    }
    
    func getChats(completion: @escaping (ChatModel) -> Void ) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        
        let query = db.child("Chats/\(correctSelfEmail)")
        
        query.observe(.value) { snapshot in
            guard snapshot.exists() else { return }
            guard let data = snapshot.value as? [String:[String:Any]] else { return }
            
            data.forEach { (key: String, value: [String:Any]) in
                let lastMessageDateValue = value["lastMessageDate"] as? String
                let lastMessageTextValue = value["lastMessageText"] as? String
                let userEmail = key
                
                let userInfoQuery = self.db.child("Users/\(userEmail)")
                userInfoQuery.removeAllObservers()
                
                userInfoQuery.observe(.value) { snapshot in
                    guard snapshot.exists() else { return }
                    guard let data = snapshot.value as? [String:Any] else { return }
                    
                    let userUsernameValue = data["username"] as? String
                    let userNameValue = data["name"] as? String
                    let userSurnameValue = data["surname"] as? String
                    let userOnlineStatusValue = data["isOnline"] as? Bool
                    
                    let unreadedMessagesQuery = self.db
                        .child("Conversations/\(correctSelfEmail)/conversation-with-\(userEmail)")
                        .queryOrdered(byChild: "isRead")
                        .queryEqual(toValue: false)
                        .queryLimited(toLast: 50)
                    unreadedMessagesQuery.removeAllObservers()
                    
                    unreadedMessagesQuery.observe(.value) { snapshot in
                        guard snapshot.exists() else {
                            completion(ChatModel(
                                email: userEmail,
                                fullname: "\(userNameValue ?? "Unknown") \(userSurnameValue ?? "Unknown")",
                                lastMessageDate: lastMessageDateValue,
                                lastMessageText: lastMessageTextValue,
                                username: userUsernameValue,
                                unreadedMessagesCount: 0,
                                isOnline: userOnlineStatusValue
                            ))
                            return
                        }
                        guard let data = snapshot.value as? [String:[String:Any]] else { return }
                        
                        var unreadedMessagesCounter = 0
                        
                        data.forEach { (key: String, value: [String:Any]) in
                            guard value["selfSender"] as? Bool == false else { return }
                            unreadedMessagesCounter += 1
                        }
                        
                        completion(ChatModel(
                            email: userEmail,
                            fullname: "\(userNameValue ?? "Unknown") \(userSurnameValue ?? "Unknown")",
                            lastMessageDate: lastMessageDateValue,
                            lastMessageText: lastMessageTextValue,
                            username: userUsernameValue,
                            unreadedMessagesCount: unreadedMessagesCounter,
                            isOnline: userOnlineStatusValue
                        ))
                    }
                }
            }
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
    
    func userOnline() {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email ?? "")
        
        db.child("Users/\(correctSelfEmail)/isOnline").setValue(true)
    }
    
    func userOffline() {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email ?? "")
        
        db.child("Users/\(correctSelfEmail)/isOnline").setValue(false)
    }
    
    func checkUserStatus(otherEmail: String, completion: @escaping (Bool) -> Void) {
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)
        
        db.child("Users/\(correctOtherEmail)/isOnline").observe(.value) { data in
            guard data.exists() else { return }
            guard let isOnline = data.value as? Bool else { return }
            completion(isOnline)
        }
    }
    
    func removeConversationObservers(with email: String, withOnlineStatus: Bool) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: email)
        
        db.child("Conversations").child(correctSelfEmail).child("conversation-with-\(correctOtherEmail)").removeAllObservers()
        guard withOnlineStatus else { return }
        db.child("Users/\(correctOtherEmail)/isOnline").removeAllObservers()
    }
}
