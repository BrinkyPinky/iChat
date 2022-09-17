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
    @IBOutlet var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.underlined()
        nameTextField.underlined()
        surnameTextField.underlined()
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
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.view.frame = CGRect(
            x: 0,
            y: self.view.frame.height - (stackView.frame.height + 50),
            width: self.view.frame.width,
            height: stackView.frame.height + 50
        )
        self.view.layer.cornerRadius = 20
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChangeUserProfileViewController {
    @objc func onKeyboardWillChangeFrame(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
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
            self.view.frame.origin.y = -(keyboardFrame.height - 75)
        }, completion: nil)
    }
}
