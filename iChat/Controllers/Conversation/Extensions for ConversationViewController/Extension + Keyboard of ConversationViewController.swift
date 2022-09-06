//
//  Extension + Keyboard of ConversationViewController.swift
//  iChat
//
//  Created by Егор Шилов on 05.09.2022.
//

import UIKit



// MARK: Keyboard will change frame
extension ConversationViewController {
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
        
        let keyboardAnimationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        let currentScrollViewPosition = conversationCollectionView.contentOffset
        
        guard currentScrollViewPosition.y != 0 else { return }
        self.conversationCollectionView.contentOffset = CGPoint(x: 0, y: currentScrollViewPosition.y + intersection.height)
    }
}
