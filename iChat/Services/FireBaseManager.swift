//
//  NetworkManager.swift
//  iChat
//
//  Created by Егор Шилов on 26.08.2022.
//

import FirebaseAuth

class FireBaseManager {
    static let shared = FireBaseManager()
    
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
}
