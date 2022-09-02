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
    
    func createUser(username: String, email: String, name: String, surname: String) {
        var correctEmail = email.replacingOccurrences(of: ".", with: "-")
        correctEmail = correctEmail.replacingOccurrences(of: "@", with: "-")
        
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
        
        let databaseRef = db.child("Users")
        let query = databaseRef.queryOrdered(byChild: "usernameForSearch").queryStarting(atValue: usernameLowered).queryLimited(toFirst: 10)

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
                    email: emailValue,
                    name: nameValue,
                    surname: surnameValue,
                    username: usernameValue
                )
                users.append(user)
            }
            completion(users)
        }
    }
}
