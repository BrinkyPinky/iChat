//
//  UserImageModel.swift
//  iChat
//
//  Created by Егор Шилов on 13.09.2022.
//

import Foundation
import RealmSwift

class UserImageModel: Object {
    @Persisted(primaryKey: true) var email: String?
    @Persisted var imageData: Data
    
    convenience init(
        email: String?,
        imageData: Data
    ) {
        self.init()
        self.email = email
        self.imageData = imageData
    }
}
