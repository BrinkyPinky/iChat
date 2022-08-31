//
//  ValidationManager.swift
//  iChat
//
//  Created by Егор Шилов on 31.08.2022.
//

import Foundation

class ValidationManager {
    static let shared = ValidationManager()
    
    func checkMailValidation(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailIsValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        return emailIsValid
    }
    
    func checkNameValidation(name: String) -> Bool {
        let nameRegex = "[a-zA-Z0-9]([._-](?![-])|[a-zA-Z0-9]){0,12}[a-zA-Z0-9]$"
        let nameIsValid = NSPredicate(format:"SELF MATCHES %@", nameRegex).evaluate(with: name)
        return nameIsValid
    }
}
