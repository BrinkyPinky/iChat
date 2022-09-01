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
    
    func createUser(email: String, name: String, surname: String) {
        var correctEmail = email.replacingOccurrences(of: ".", with: "-")
        correctEmail = correctEmail.replacingOccurrences(of: "@", with: "-")
        
        db.child("Users").child(correctEmail).setValue([
            "name": name,
            "surname" : surname
        ])
    }
    
    func getUsers(with email: String) {
        var correctEmail = email.replacingOccurrences(of: ".", with: "-")
        correctEmail = correctEmail.replacingOccurrences(of: "@", with: "-")
        correctEmail = correctEmail.lowercased()
        
        if correctEmail == "" {
            correctEmail = "a"
        }
        //
        //        db.child("Users").queryOrderedByValue().queryStarting(atValue: correctEmail).getData { error, data in
        //            guard let data = data else {
        //                print(error)
        //                return
        //            }
        //            print(data)
        //        }
        
        
    }
    
    func search(name: String) {
        let databaseRef = db.child("Users")
        let query = databaseRef.queryOrdered(byChild: "name").queryStarting(atValue: name).queryLimited(toFirst: 5)
        
        query.observeSingleEvent(of: .value) { (data) in
            guard data.exists() != false else { return }
            guard let value = data.value as? [String:[String:Any]] else { return }
            
            var users: [UserModel] = []
            
            value.forEach { (_, value: [String : Any]) in
                let email = value["email"] as? String
                let name = value["name"] as? String
                let surname = value["surname"] as? String
                
                let user = UserModel(email: email, name: name, surname: surname)
                users.append(user)
            }
            
            var sortedUsers: [UserModel] = []
            
            users.forEach { userModel in
                if userModel.name?.contains(name) == true {
                    sortedUsers.append(userModel)
                }
            }
        }
    }
}
