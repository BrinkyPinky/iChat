//
//  FireBaseDatabaseManager.swift
//  iChat
//
//  Created by Егор Шилов on 28.08.2022.
//

import FirebaseDatabase

class FireBaseDatabaseManager {
    static let shared = FireBaseDatabaseManager()
    
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
    
    func sendMessage(to email: String, message: String) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: email)
        
        let dbSelfDestination = db
            .child("Users")
            .child(correctSelfEmail)
            .child("conversations")
            .child("conversation-with-\(correctOtherEmail)")
        let dbOtherDestination = db
            .child("Users")
            .child(correctOtherEmail)
            .child("conversations")
            .child("conversation-with-\(correctSelfEmail)")
        
        let specifiedDate = String(Date().timeIntervalSince1970)

        dbSelfDestination.childByAutoId().setValue([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": true
        ])
        
        dbOtherDestination.childByAutoId().setValue([
            "date": specifiedDate,
            "isRead": false,
            "messageText": message,
            "selfSender": false
        ])
    }
    
    func getMessages(withEmail otherEmail: String, andLimit: Int, completion: @escaping ([MessageModel]) -> Void) {
        let correctSelfEmail = convertToCorrectEmail(email: UserLoginDataManager.shared.email!)
        let correctOtherEmail = convertToCorrectEmail(email: otherEmail)

        let query = db
            .child("Users")
            .child(correctSelfEmail)
            .child("conversations")
            .child("conversation-with-\(correctOtherEmail)")
            .queryLimited(toLast: UInt(andLimit))
        
        query.observe(.value) { (data) in
            guard data.exists() != false else { return }
            guard let value = data.value as? [String:[String:Any]] else { return }
            
            var messages = [MessageModel]()
            
            value.forEach { (_, value: [String : Any]) in
                let messageTextValue = value["messageText"] as? String
                let dateValue = value["date"] as? String
                let isReadValue = value["isRead"] as? Bool
                let selfSenderValue = value["selfSender"] as? Bool
                
                print(dateValue)
                
                let message = MessageModel(
                    messageText: messageTextValue ?? "No message information",
                    date: dateValue ?? "No date",
                    isRead: isReadValue ?? false,
                    selfSender: selfSenderValue ?? false
                )
                
                messages.append(message)
            }
            let sortedMessages = messages.sorted(by: {$0.date < $1.date})
            completion(sortedMessages)
        }
    }
    
    func removeObservers() {
        db.removeAllObservers()
    }
}
