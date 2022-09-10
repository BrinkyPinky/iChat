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
    init(view: SignUpViewController)
    func signUpButtonTapped(username: String?, name: String?, surname: String?, email: String?, password: String?)
    func emailTextFieldDidChanged(email: String?)
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
        
    var viewModelDidChanged: ((SignUpViewModelProtocol) -> Void)?
    
    func emailTextFieldDidChanged(email: String?) {
        emailIsValid = ValidationManager.shared.checkMailValidation(email: email ?? "")
    }
    
    func signUpButtonTapped(username: String?, name: String?, surname: String?, email: String?, password: String?) {
        let isNameValid = ValidationManager.shared.checkNameValidation(name: name ?? "")
        let isSurnameValid = ValidationManager.shared.checkNameValidation(name: surname ?? "")
        
        if isNameValid == true && isSurnameValid == true {
            FireBaseAuthManager.shared.signUp(email: email ?? "", password: password ?? "") { [unowned self] error in
                
                guard let error = error else {
                    FireBaseDatabaseManager.shared.createUser(username: username ?? "", email: email ?? "", name: name ?? "", surname: surname ?? "")
                    UserLoginDataManager.shared.saveData(email: email ?? "", password: password ?? "")
                    UserLoginDataManager.shared.getUserInformation(email: email ?? "")
                    view.showViewController(with: "MainTabBar")
                    return
                }
                
                view.alert(message: error.localizedDescription)
            }
        } else {
            view.alert(message: "Invalid Name or Username")
        }
    }
}
