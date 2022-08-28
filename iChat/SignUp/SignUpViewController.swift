//
//  SignUpViewController.swift
//  iChat
//
//  Created by Егор Шилов on 26.08.2022.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var signUpButton: UIButton!
    
    var viewModel: SignUpViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SignUpViewModel(view: self)
        setupUI()
    }
    
    @IBAction private func signUpButtonAction(_ sender: Any) {
        viewModel.signUpButtonTapped(
            name: firstNameTextField.text ?? "",
            surname: lastNameTextField.text ?? "",
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }
    
    @objc private func textFieldDidChange() {
        viewModel.checkMailIsValid(email: emailTextField.text ?? "")
        updateEmailValidImage(with: viewModel.emailIsValid ? "checkmark" : "xmark")
    }

    
    private func updateEmailValidImage(with imageName: String) {
        emailTextField.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(systemName: imageName)
        imageView.image = image
        imageView.tintColor = viewModel.emailIsValid ? UIColor.green : UIColor.red
        emailTextField.rightView = imageView
    }
    
    private func setupUI() {
        signUpButton.configuration?.cornerStyle = .capsule
        
        viewModel.viewModelDidChanged = { [unowned self] updatedViewModel in
            viewModel = updatedViewModel
        }
        
        firstNameTextField.underlined()
        lastNameTextField.underlined()
        emailTextField.underlined()
        passwordTextField.underlined()
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func segueToMessenger() {
        performSegue(withIdentifier: "ShowMessenger", sender: nil)
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

