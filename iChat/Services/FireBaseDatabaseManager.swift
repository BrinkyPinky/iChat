//
//  FireBaseDatabaseManager.swift
//  iChat
//
//  Created by Егор Шилов on 28.08.2022.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class FireBaseDatabaseManager {
    static let shared = FireBaseDatabaseManager()
    
    var isPaginating = false
    
    var db = Firestore.firestore()
    
    var messagesListener: ListenerRegistration?
    var userStatusListener: ListenerRegistration?
    
    // MARK: Registration
    
    func createUser(username: String, email: String, name: String, surname: String) {
        db.collection("Users").document("\(email)").setData([
            "email": email,
            "name": name,
            "surname": surname,
            "username": username,
            "usernameForSearch": username.lowercased(),
            "isOnline": true
        ])
    }
    
    func checkIfUserNameIsFree(username: String, completion: @escaping (Bool) -> Void) {
        let usernameForSearch = username.lowercased()
        
        db.collection("Users").whereField("usernameForSearch", isEqualTo: usernameForSearch).limit(to: 1).getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            
            guard querySnapshot.documents.first != nil else {
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    func getSelfUser(email: String, completion: @escaping (String, String) -> Void) {
        db.collection("Users").document(email).getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot?.data() else { return }
            
            let nameValue = documentSnapshot["name"] as? String
            let surnameValue = documentSnapshot["surname"] as? String
            let usernameValue = documentSnapshot["username"] as? String
            
            completion("\(nameValue ?? "unknown") \(surnameValue ?? "unknown")", usernameValue ?? "unknown")
        }
    }
    
    // MARK: SearchUser
    
    func searchUser(username: String, completion: @escaping ([UserModel]) -> Void) {
        let usernameLowered = username.lowercased()
        
        let query = db
            .collection("Users")
            .order(by: "usernameForSearch")
            .start(at: [usernameLowered])
            .limit(to: 20)
        
        query.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot?.documents else { return }
            
            var users: [UserModel] = []
            
            querySnapshot.forEach { dataRaw in
                let data = dataRaw.data()
                
                let emailValue = data["email"] as? String
                let nameValue = data["name"] as? String
                let surnameValue = data["surname"] as? String
                let usernameValue = data["username"] as? String
                
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
    
    // MARK: MessagesInteraction
    
    func sendMessage(to email: String, withName name: String, andUsername username: String, message: String) {
        let selfEmail = UserLoginDataManager.shared.email!
        let otherEmail = email
        
        let batch = db.batch()
        
        let specifiedDate = String(Date().timeIntervalSince1970)
        
        let dbSelfDestination = db
            .collection("Conversations")
            .document(selfEmail)
            .collection(otherEmail)
            .document(specifiedDate)
        batch.setData([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": true,
            "messageID": specifiedDate
        ], forDocument: dbSelfDestination)
        
        let dbOtherDestination = db
            .collection("Conversations")
            .document(otherEmail)
            .collection(selfEmail)
            .document(specifiedDate)
        batch.setData([
            "date": specifiedDate,
            "isRead": true,
            "messageText": message,
            "selfSender": false,
            "messageID": specifiedDate
        ], forDocument: dbOtherDestination)
                
        batch.commit() { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
    
    func getMessages(withEmail otherEmail: String, andLimit limit: Int, completion: @escaping ([MessageModel]) -> Void) {
        self.isPaginating = true
        
        let selfEmail = UserLoginDataManager.shared.email!
        
        var messages = [MessageModel]()
        
        let query = db
            .collection("Conversations")
            .document(selfEmail)
            .collection(otherEmail)
            .order(by: "date")
            .limit(toLast: limit)
        
        messagesListener = query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot?.documents else { return }
            
            print("smth")
            
            snapshot.forEach { rawData in
                let data = rawData.data()
                let messageTextValue = data["messageText"] as? String
                let dateValue = data["date"] as? String
                let isReadValue = data["isRead"] as? Bool
                let selfSenderValue = data["selfSender"] as? Bool
                let messageValue = data["messageID"] as? String
                
                let message = MessageModel(
                    messageText: messageTextValue ?? "No message information",
                    date: dateValue ?? "No date",
                    isRead: isReadValue ?? false,
                    selfSender: selfSenderValue ?? false,
                    messageID: messageValue ?? ""
                )
                messages.append(message)
            }
            
            completion(messages)
            self.isPaginating = false
        }
    }
    
    func deleteMessageForYourself(messageID: String, otherEmail: String) {
        let selfEmail = UserLoginDataManager.shared.email!
        
        let dbSelfDestination = db
            .collection("Conversations")
            .document(selfEmail)
            .collection(otherEmail)
            .document("\(messageID)")
        
        dbSelfDestination.delete() { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
    
    func deleteMessageForAll(messageID: String, otherEmail: String) {
        let selfEmail = UserLoginDataManager.shared.email!

        let batch = db.batch()

        let dbSelfDestination = db
            .collection("Conversations")
            .document(selfEmail)
            .collection(otherEmail)
            .document("\(messageID)")
        
        let dbOtherDestination = db
            .collection("Conversations")
            .document(otherEmail)
            .collection(selfEmail)
            .document("\(messageID)")
        
        batch.deleteDocument(dbSelfDestination)
        batch.deleteDocument(dbOtherDestination)
        
        batch.commit { error in
            guard let error = error else { return }
            print(error.localizedDescription)
        }
    }
    
    func readMessage(messageID: String, otherEmail: String) {
        let selfEmail = UserLoginDataManager.shared.email!
        
        let dbOtherDestination = db
            .collection("Conversations")
            .document(selfEmail)
            .collection(otherEmail)
            .document(messageID)
        
        dbOtherDestination.updateData(["isRead":true])
    }
    
    func getChats(completion: @escaping ([ChatModel]) -> Void ) {
        //        let query = db.child("Users/\(correctSelfEmail)/listOfConversations").queryLimited(toFirst: 25)
        //
        //        query.observe(.value) { data in
        //            guard data.exists() != false else { return }
        //            guard let chatsValues = data.value as? [String:[String:Any]] else { return }
        //
        //            var chats = [ChatModel]()
        //
        //            chatsValues.forEach { (_, value: [String : Any]) in
        //                let usernameValue = value["username"] as? String
        //                let fullnameValue = value["fullName"] as? String
        //                let emailValue = value["email"] as? String
        //                let lastMessageTextValue = value["lastMessageText"] as? String
        //                let lastMessageDateValue = value["lastMessageDate"] as? String
        //                let isOnlineValue = value["isOnline"] as? Bool
        //
        //                let unreadedMessagesValue = value["unreadedMessages"] as? [String:Any]
        //                let unreadedMessagesCount = unreadedMessagesValue?.count
        //
        //                let chat = ChatModel(
        //                    email: emailValue,
        //                    fullname: fullnameValue,
        //                    lastMessageDate: lastMessageDateValue,
        //                    lastMessageText: lastMessageTextValue,
        //                    username: usernameValue,
        //                    unreadedMessagesCount: unreadedMessagesCount ?? 0,
        //                    isOnline: isOnlineValue
        //                )
        //
        //                chats.append(chat)
        //            }
        //
        //            let sortedChats = chats.sorted(by: { Double($0.lastMessageDate ?? "0")! > Double($1.lastMessageDate ?? "0")! })
        //            completion(sortedChats)
        //        }
    }
    
    
    func userOnline() {
        let SelfEmail = UserLoginDataManager.shared.email ?? ""
        
        db.collection("Users").document("\(SelfEmail)").updateData(["isOnline":true])
    }
    
    func userOffline() {
        let SelfEmail = UserLoginDataManager.shared.email ?? ""
        
        db.collection("Users").document("\(SelfEmail)").updateData(["isOnline":false])
    }
    
    
    func checkUserStatus(otherEmail: String, completion: @escaping (Bool) -> Void) {
        userStatusListener = db.collection("Users").document(otherEmail).addSnapshotListener { snapshot, error in
            guard let rawData = snapshot else { return }
            let data = rawData.data()
            guard let isOnline = data?["isOnline"] as? Bool else { return }
            completion(isOnline)
        }
        
    }
    
    
    func removeConversationObservers(with email: String, withOnlineStatus: Bool) {
        messagesListener?.remove()
        userStatusListener?.remove()
    }
}
