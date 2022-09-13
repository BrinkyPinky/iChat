//
//  SettingsViewModel.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import Foundation

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
    func viewLoad()
    func pickedImage(with image: Data?)
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
                    self.view.present(self.view.imagePickerController, animated: true, completion: nil)
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
                            self.view.showAlert(title: "Check your E-Mail", message: "Instructions have been sent to your e-mail")
                            return
                        }
                        self.view.showAlert(title: "Error", message: error.localizedDescription)
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
    
    private var imageData: Data? {
        didSet {
            guard let imageData = imageData else {
                return
            }
            view.displayUserImage(with: imageData)
        }
    }

    func viewLoad() {
        UserLoginDataManager.shared.fetchData()
        
        view.displayFullname(with: UserLoginDataManager.shared.fullname ?? "Unknown")
        view.displayUsername(with: "@\(UserLoginDataManager.shared.username ?? "Unknown")")
        
        FireBaseStorageManager.shared.getUserImage(emailIfOtherUser: nil) { [unowned self] imageData in
            self.imageData = imageData
        }
        
    }
    
    func pickedImage(with image: Data?) {
        FireBaseStorageManager.shared.uploadUserImage(with: image!)
    }
}
