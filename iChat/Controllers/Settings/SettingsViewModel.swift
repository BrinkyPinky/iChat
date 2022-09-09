//
//  SettingsViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import Foundation
import UIKit

enum SettingType {
    case simple, logout
}

struct SettingCellViewModel: CellIdentifiable {
    var cellIdentifier: String {
        "SettingCell"
    }
    
    let type: SettingType
    let text: String
    let imagename: String?
    let handler: (() -> Void)
}

protocol SettingsViewModelProtocol {
    var rows: [[CellIdentifiable]] { get }
    init(view: SettingsTableViewController)
    func pickedImage(with image: UIImage?)
}

class SettingsViewModel: SettingsViewModelProtocol {
    unowned var view: SettingsTableViewController
    
    lazy var rows: [[CellIdentifiable]] = [
        [
            SettingCellViewModel(
                type: .simple,
                text: "Add or update profile photo",
                imagename: "square.and.arrow.down",
                handler: {
                    let vc = UIImagePickerController()
                    vc.sourceType = .photoLibrary
                    vc.delegate = self.view
                    vc.allowsEditing = true
                    self.view.present(vc, animated: true, completion: nil)
                }
            ),
            SettingCellViewModel(
                type: .simple,
                text: "Reset password",
                imagename: "lock",
                handler: {
                    let email = UserLoginDataManager.shared.email
                    FireBaseAuthManager.shared.recoverPassword(email: email ?? "") { error in
                        guard let error = error else {
                            self.view.showAlert(with: "Instructions have been sent to your e-mail")
                            return
                        }
                        self.view.showAlert(with: error.localizedDescription)
                    }
                }
            )
        ],
        [
            SettingCellViewModel(
                type: .logout,
                text: "Log Out",
                imagename: nil,
                handler: {
                    UserLoginDataManager.shared.removeData()
                    self.view.showViewController(with: "NavigationControllerLogin")
                }
            )
        ]
    ]
    
    required init(view: SettingsTableViewController) {
        self.view = view
    }
    
    func pickedImage(with image: UIImage?) {
        
    }
}
