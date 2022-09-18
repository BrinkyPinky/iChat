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
    var username: String?
    var name: String?
    var surname: String?
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        email = UserDefaults.standard.string(forKey: "email")
        password = UserDefaults.standard.string(forKey: "password")
        username = UserDefaults.standard.string(forKey: "username")
        name = UserDefaults.standard.string(forKey: "name")
        surname = UserDefaults.standard.string(forKey: "surname")
    }
    
    func saveData(email: String, password: String) {
        let correctEmail = email.lowercased()
        UserDefaults.standard.set(correctEmail, forKey: "email")
        UserDefaults.standard.set(password, forKey: "password")
        fetchData()
    }
    
    func saveUserInfo(username: String, name: String, surname: String) {
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(surname, forKey: "surname")
    }
    
    func removeData() {
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "surname")
        fetchData()
    }
}
