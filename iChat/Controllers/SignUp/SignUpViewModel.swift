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
        guard ValidationManager.shared.checkNameValidation(name: username ?? "") else {
            view.alert(message: "Invalid Username")
            return
        }
        
        var usernameIsFree: Bool? {
            didSet {
                guard usernameIsFree ?? false else {
                    view.alert(message: "This username is already in use")
                    return
                }
                continueSignUp()
            }
        }
        
        FireBaseDatabaseManager.shared.checkIfUserNameIsFree(username: username ?? "") { isFree in
            usernameIsFree = isFree
        }

        func continueSignUp() {
            
            guard ValidationManager.shared.checkNameValidation(name: name ?? "") else {
                view.alert(message: "Invalid name")
                return
            }
            
            guard ValidationManager.shared.checkNameValidation(name: surname ?? "") else {
                view.alert(message: "Invalid surname")
                return
            }
            
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
        }
    }
}
