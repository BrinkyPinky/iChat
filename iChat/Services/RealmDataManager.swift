//
//  RealmDataManager.swift
//  iChat
//
//  Created by Егор Шилов on 13.09.2022.
//

import Foundation
import RealmSwift

class RealmDataManager {
    static let shared = RealmDataManager()
    
    let realm = try! Realm()

    // MARK: Chats
    
    func writeLastChats(chatModel: [ChatModel]) {
        try! realm.write {
            realm.add(chatModel, update: .all)
        }
    }

    func getLastChats() -> [ChatModel] {
        return Array(realm.objects(ChatModel.self))
    }
    
    // MARK: Images
    
    func saveUserImage(imageData: Data, email: String) {
        let imageModel = UserImageModel(email: email, imageData: imageData)
        
        try! realm.write {
            realm.add(imageModel, update: .all)
        }
    }
    
    func getUserImage(email: String) -> Data? {
        return realm.object(ofType: UserImageModel.self, forPrimaryKey: email)?.imageData
    }
    
    // MARK: SelfUser
    
    func saveSelfUser(fullname: String, username: String) {
        
    }
    
    
    // MARK: Clean realm data
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
