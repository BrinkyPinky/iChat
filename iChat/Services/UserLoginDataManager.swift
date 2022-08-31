//
//  UserLoginDataManager.swift
//  iChat
//
//  Created by Егор Шилов on 28.08.2022.
//

import Foundation

class UserLoginDataManager {
    static let shared = UserLoginDataManager()
    
    var email: String?
    var password: String?
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        email = UserDefaults.standard.string(forKey: "email")
        password = UserDefaults.standard.string(forKey: "password")
    }
    
    func saveData(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
    }
    
    func removeData() {
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
    }
}
