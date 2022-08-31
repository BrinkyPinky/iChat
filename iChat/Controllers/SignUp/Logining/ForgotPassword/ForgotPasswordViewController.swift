//
//  ForgotPasswordViewController.swift
//  iChat
//
//  Created by Егор Шилов on 31.08.2022.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var sendEmailButton: UIButton!
    
    private var viewModel: ForgotPasswordViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func sendEmailButtonAction(_ sender: Any) {
        viewModel.sendEmailButtonPressed(with: emailTextField.text)
    }
    
    private func setupUI() {
        emailTextField.underlined()
        sendEmailButton.configuration?.cornerStyle = .capsule
        viewModel = ForgotPasswordViewModel(self)
    }
    
    func showAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
