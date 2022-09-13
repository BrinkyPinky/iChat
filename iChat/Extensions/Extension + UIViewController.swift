//
//  Extension + UIViewController.swift
//  iChat
//
//  Created by Егор Шилов on 31.08.2022.
//

import UIKit

extension UIViewController {
    
    // MARK: show another view controller
    
    private func resetWindow(with vc: UIViewController?) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("could not get scene delegate ")
        }
        sceneDelegate.window?.rootViewController = vc
    }
    
    func showViewController(with id: String) {
        let vc = storyboard?.instantiateViewController(identifier: id)
        resetWindow(with: vc)
    }
    
    // MARK: hide keyboard
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
