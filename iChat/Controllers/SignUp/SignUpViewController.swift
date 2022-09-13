//
//  SignUpViewController.swift
//  iChat
//
//  Created by Егор Шилов on 26.08.2022.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var usernameTextField: UITextField!
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onKeyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @IBAction private func signUpButtonAction(_ sender: Any) {
        viewModel.signUpButtonTapped(
            username: usernameTextField.text,
            name: firstNameTextField.text,
            surname: lastNameTextField.text,
            email: emailTextField.text,
            password: passwordTextField.text
        )
    }
    
    @objc private func textFieldDidChange() {
        viewModel.emailTextFieldDidChanged(email: emailTextField.text)
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
        self.hideKeyboardWhenTappedAround()
        
        signUpButton.configuration?.cornerStyle = .capsule
        
        viewModel.viewModelDidChanged = { [unowned self] updatedViewModel in
            viewModel = updatedViewModel
        }
        
        usernameTextField.underlined()
        firstNameTextField.underlined()
        lastNameTextField.underlined()
        emailTextField.underlined()
        passwordTextField.underlined()
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension SignUpViewController {
    @objc func onKeyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
               
        // MARK: Animation settings
        
        let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        // MARK: SafeArea when keyboard appears
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
