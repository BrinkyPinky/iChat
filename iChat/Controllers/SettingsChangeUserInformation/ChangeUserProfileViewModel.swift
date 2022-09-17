//
//  ChangeUserProfileViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 17.09.2022.
//

import Foundation

protocol ChangeUserProfileViewModelProtocol {
    func doneButtonPressed(username: String?, name: String?, surname: String?, completion: @escaping (Bool) -> Void)
    init(view: ChangeUserProfileViewController)
}

class ChangeUserProfileViewModel: ChangeUserProfileViewModelProtocol {
    
    unowned var view: ChangeUserProfileViewController!
    
    required init(view: ChangeUserProfileViewController) {
        self.view = view
    }
    
    func doneButtonPressed(username: String?, name: String?, surname: String?, completion: @escaping (Bool) -> Void) {
        guard ValidationManager.shared.checkNameValidation(name: username ?? "") else {
            view.showAlert(message: "Invalid username")
            return
        }
        guard ValidationManager.shared.checkNameValidation(name: name ?? "") else {
            view.showAlert(message: "Invalid name")
            return
        }
        guard ValidationManager.shared.checkNameValidation(name: surname ?? "") else {
            view.showAlert(message: "Invalid surname")
            return
        }
        FireBaseDatabaseManager.shared.checkIfUserNameIsFree(username: username ?? "", completion: { isFree in
            guard isFree else {
                self.view.showAlert(message: "Username already in use")
                completion(false)
                return
            }
            FireBaseDatabaseManager.shared.changeUserInformation(
                username: username ?? "",
                name: name ?? "",
                surname: surname ?? ""
            )
            completion(true)
        })
    }
}
