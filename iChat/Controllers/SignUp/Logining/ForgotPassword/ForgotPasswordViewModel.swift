//
//  ForgotPasswordViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 31.08.2022.
//

import Foundation

protocol ForgotPasswordViewModelProtocol {
    init(_ view: ForgotPasswordViewController)
    func sendEmailButtonPressed(with email: String?)
}

class ForgotPasswordViewModel: ForgotPasswordViewModelProtocol {
    
    unowned private var view: ForgotPasswordViewController!
    
    required init(_ view: ForgotPasswordViewController) {
        self.view = view
    }
    
    // MARK: Send Email Button Tapped
    
    func sendEmailButtonPressed(with email: String?) {
        FireBaseAuthManager.shared.recoverPassword(email: email ?? "") { [unowned self] error in
            guard let error = error else {
                view.showAlert(with: "An email was successfully sent to reset the password.")
                
                return
            }
            view.showAlert(with: error.localizedDescription)
        }
    }
}
