//
//  ConversationViewController.swift
//  iChat
//
//  Created by Егор Шилов on 03.09.2022.
//

import UIKit

class ConversationViewController: UIViewController {
    
    let someExampleArray = ["Privet kak dela epgta?", "Hellooo!!!!", "HIIII!!!!!", "I", "Privet kak dela epgta?", "Hellooo!!!!", "HIIII!!!!!", "I", "Privet kak dela epgta?", "Hellooo!!!!", "HIIII!!!!!", "I", "Privet kak dela epgta?", "Hellooo!!!!", "HIIII!!!!!", "I"]
    
    @IBOutlet private var conversationCollectionView: UICollectionView!
    @IBOutlet private var inputMessageToolBar: UIToolbar!
    private let messageTextView = UITextView()
    private let sendMessageButton = UIButton()
    private let stackViewForToolBar = UIStackView()
    
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolBar()
        setupNavigationBarAndCollectionView()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension ConversationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        someExampleArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! ConversationCollectionViewCell
        
        cell.text = someExampleArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

// MARK: Keyboard will change frame
extension ConversationViewController {
    @objc private func onKeyboardWillChangeFrame(_ notification: NSNotification) {
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
    }
}


//MARK: TextFieldDidChange

extension ConversationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        guard textView.contentSize.height < 100 else {
            textView.isScrollEnabled = true
            return
        }
        
        textView.isScrollEnabled = false
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                let height = estimatedSize.height
                constraint.constant = height
            }
        }
        
        inputMessageToolBar.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height + 13
            }
        }
    }
}

// MARK: Setup Input Tool Bar

extension ConversationViewController {
    private func setupToolBar() {
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.backgroundColor = .quaternarySystemFill
        messageTextView.layer.cornerRadius = 18
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageTextView.delegate = self
        messageTextView.text = "Message"
        messageTextView.textColor = .lightGray
        
        sendMessageButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendMessageButton.contentMode = .scaleAspectFit
        sendMessageButton.contentHorizontalAlignment = .fill
        sendMessageButton.contentVerticalAlignment = .fill
        
        stackViewForToolBar.axis = NSLayoutConstraint.Axis.horizontal
        stackViewForToolBar.distribution  = UIStackView.Distribution.equalSpacing
        stackViewForToolBar.alignment = UIStackView.Alignment.bottom
        stackViewForToolBar.spacing = 8
        stackViewForToolBar.addArrangedSubview(messageTextView)
        stackViewForToolBar.addArrangedSubview(sendMessageButton)
        
        let stackViewToolBarItem = UIBarButtonItem(customView: stackViewForToolBar)
        inputMessageToolBar.items = [stackViewToolBarItem]
        
        
        let size = CGSize(width: messageTextView.frame.size.width, height: .infinity)
        let estimatedSize = messageTextView.sizeThatFits(size)
        [
            sendMessageButton.widthAnchor.constraint(equalToConstant: 36),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 36),
            messageTextView.heightAnchor.constraint(equalToConstant: estimatedSize.height),
            messageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -8),
            inputMessageToolBar.heightAnchor.constraint(equalToConstant: estimatedSize.height + 13)
        ].forEach({ $0.isActive = true })
    }
}

// MARK: Nav Bar and Collection View Setup
extension ConversationViewController {
    private func setupNavigationBarAndCollectionView() {
        conversationCollectionView.clipsToBounds = true
        conversationCollectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        conversationCollectionView.layer.cornerRadius = 50
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = UIColor(red: 234/255, green: 239/255, blue: 252/255, alpha: 1)
        navigationBarAppearance.shadowColor = .clear
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
    }
}
