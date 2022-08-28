//
//  SignUpViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 26.08.2022.
//

import Foundation
import UIKit
import Alamofire

protocol SignUpViewModelProtocol: AnyObject {
    var errorMessage: String { get }
    var emailIsValid: Bool { get }
    var viewModelDidChanged: ((SignUpViewModelProtocol) -> Void)? { get set }
    init(view: SignUpViewController)
    func checkMailIsValid(email: String)
    func isValidNameOrSurname(with name: String) -> Bool
    func signUpButtonTapped(name: String, surname: String, email: String, password: String)
}

class SignUpViewModel: SignUpViewModelProtocol {
    
    unowned var view: SignUpViewController
    
    required init(view: SignUpViewController) {
        self.view = view
    }
    
    var emailIsValid: Bool = false {
        didSet {
            viewModelDidChanged?(self)
        }
    }
    
    var errorMessage: String = ""
    
    var viewModelDidChanged: ((SignUpViewModelProtocol) -> Void)?
    
    func checkMailIsValid(email: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailIsValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        self.emailIsValid = emailIsValid
    }
    
    func isValidNameOrSurname(with name: String) -> Bool {
        let nameRegex = "[a-zA-Z0-9]([._-](?![-])|[a-zA-Z0-9]){0,12}[a-zA-Z0-9]$"
        let nameIsValid = NSPredicate(format:"SELF MATCHES %@", nameRegex).evaluate(with: name)
        return nameIsValid
    }
    
    func signUpButtonTapped(name: String, surname: String, email: String, password: String) {
        let isNameValid = isValidNameOrSurname(with: name)
        let isSurnameValid = isValidNameOrSurname(with: surname)
        
        if isNameValid == true && isSurnameValid == true {
            FireBaseAuthManager.shared.signUp(email: email, password: password) { [unowned self] error in
                
                guard let error = error else {
                    view.segueToMessenger()
                    FireBaseDatabaseManager.shared.createUser(email: email, name: name, surname: surname)
                    UserLoginDataManager.shared.saveData(email: email, password: password)
                    return
                }
                
                view.alert(message: error.localizedDescription)
            }
        } else {
            view.alert(message: "Invalid Name or Username")
        }
    }
}
