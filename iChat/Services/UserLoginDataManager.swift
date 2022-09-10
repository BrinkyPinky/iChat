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
    var fullname: String?
    var username: String?
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        email = UserDefaults.standard.string(forKey: "email")
        password = UserDefaults.standard.string(forKey: "password")
        fullname = UserDefaults.standard.string(forKey: "fullname")
        username = UserDefaults.standard.string(forKey: "username")
    }
    
    func saveData(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
        fetchData()
    }
    
    func getUserInformation(email: String) {
        FireBaseDatabaseManager.shared.getSelfUser(email: email) { fullnameValue, usernameValue in
            UserDefaults.standard.set(fullnameValue, forKey: "fullname")
            UserDefaults.standard.set(usernameValue, forKey: "username")
        }
        fetchData()
    }
    
    func removeData() {
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "fullname")
        UserDefaults.standard.removeObject(forKey: "username")
    }
}
