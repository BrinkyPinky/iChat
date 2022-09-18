//
//  ChangeUserProfileViewController.swift
//  iChat
//
//  Created by Егор Шилов on 17.09.2022.
//

import UIKit

class ChangeUserProfileViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var surnameTextField: UITextField!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var stackView: UIStackView!
    
    private var viewOriginY: CGFloat = 0
    
    private var viewModel: ChangeUserProfileViewModelProtocol!
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ChangeUserProfileViewModel(view: self)
        viewModel.didLoad()
        
        usernameTextField.underlined()
        nameTextField.underlined()
        surnameTextField.underlined()
        doneButton.configuration?.cornerStyle = .capsule
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowForResizing),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideForResizing),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: Calculate height of view
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.view.frame = CGRect(
            x: 0,
            y: self.view.frame.height - (stackView.frame.height + 50),
            width: self.view.frame.width,
            height: stackView.frame.height + 50
        )
        self.view.layer.cornerRadius = 20
        
        viewOriginY = self.view.frame.origin.y
    }
    
    func displayUserInfo(username: String, name: String, surname: String) {
        usernameTextField.text = username
        nameTextField.text = name
        surnameTextField.text = surname
    }
    
    // MARK: Done Button Action
    
    @IBAction private  func doneButtonAction(_ sender: Any) {
        viewModel.doneButtonPressed(username: usernameTextField.text, name: nameTextField.text, surname: surnameTextField.text) { isDismissNeeded in
            guard isDismissNeeded else { return }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Alert Method
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension ChangeUserProfileViewController {
    @objc private func keyboardWillShowForResizing(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
        self.view.frame.origin.y = keyboardSize.origin.y - keyboardSize.height
    }
    
    @objc private func keyboardWillHideForResizing(notification: Notification) {
        self.view.frame.origin.y = self.viewOriginY
    }
}
