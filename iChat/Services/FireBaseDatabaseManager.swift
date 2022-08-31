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
    
//    func getData() {
//        ref.child("Users").child("User2").getData { error, data in
//            print(data)
//        }
//    }
}
