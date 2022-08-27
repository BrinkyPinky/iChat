//
//  SignUpViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 26.08.2022.
//

import Foundation
import UIKit

protocol SignUpViewModelProtocol: AnyObject {
    var emailIsValid: Bool { get }
    var viewModelDidChanged: ((SignUpViewModelProtocol) -> Void)? { get set }
    func checkMailIsValid(email: String)
}

class SignUpViewModel: SignUpViewModelProtocol {
    var emailIsValid: Bool = false {
        didSet {
            viewModelDidChanged?(self)
        }
    }
    
    var viewModelDidChanged: ((SignUpViewModelProtocol) -> Void)?
    
    func checkMailIsValid(email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailIsValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        self.emailIsValid = emailIsValid
    }
}
