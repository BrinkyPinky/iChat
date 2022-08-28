//
//  NetworkManager.swift
//  iChat
//
//  Created by Егор Шилов on 26.08.2022.
//

import FirebaseAuth

class FireBaseAuthManager {
    static let shared = FireBaseAuthManager()
    
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
}
