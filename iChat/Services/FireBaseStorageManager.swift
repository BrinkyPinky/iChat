//
//  FireBaseStorageManager.swift
//  iChat
//
//  Created by Егор Шилов on 09.09.2022.
//

import Foundation
import FirebaseStorage

class FireBaseStorageManager {
    static let shared = FireBaseStorageManager()
    let storageRef = Storage.storage().reference()

    
    func uploadUserImage(with data: Data) {
        var selfEmail = UserLoginDataManager.shared.email
        selfEmail = selfEmail!.replacingOccurrences(of: ".", with: "-")
        selfEmail = selfEmail!.replacingOccurrences(of: "@", with: "-")
        
        storageRef.child("UsersImages/\(selfEmail ?? "unknown").jpg").putData(data, metadata: nil) { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getUserImage(emailIfOtherUser email: String?, completion: @escaping (Data?) -> Void) {
        var selfEmail = UserLoginDataManager.shared.email
        selfEmail = selfEmail!.replacingOccurrences(of: ".", with: "-")
        selfEmail = selfEmail!.replacingOccurrences(of: "@", with: "-")

        storageRef.child("UsersImages/\(email ?? (selfEmail ?? "Unknown")).jpg").getData(maxSize: 3 * 1024 * 1024) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print(error)
            }
        }
    }
}
