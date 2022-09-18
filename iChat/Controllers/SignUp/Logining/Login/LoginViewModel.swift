//
//  LoginViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 28.08.2022.
//

import Foundation

protocol LoginViewModelProtocol {
    init(view: LoginViewController)
    func loginButtonTapped(email: String?, password: String?)
}

class LoginViewModel: LoginViewModelProtocol {
    unowned var view: LoginViewController
    
    required init(view: LoginViewController) {
        self.view = view
    }
    
    func loginButtonTapped(email: String?, password: String?) {
        FireBaseAuthManager.shared.login(email: email ?? "", password: password ?? "") { [unowned self] error in
            guard let error = error else {
                UserLoginDataManager.shared.saveData(email: email ?? "", password: password ?? "")
                view.showViewController(with: "MainTabBar")
                return
            }
            view.alert(with: error.localizedDescription)
        }
    }
}
