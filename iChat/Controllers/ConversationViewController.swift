//
//  ConversationViewController.swift
//  iChat
//
//  Created by Егор Шилов on 03.09.2022.
//

import UIKit

class ConversationViewController: UIViewController {
    
    @IBOutlet var inputMessageToolBar: UIToolbar!
    let messageTextView = UITextView()
    let button = UIButton()
    let stackViewForToolBar = UIStackView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
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
    }
}


extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        var configurator = cell.defaultContentConfiguration()
        configurator.text = "row: \(indexPath.row)"
        cell.contentConfiguration = configurator
        
        return cell
    }
    
}

// MARK: TextFieldDidChange

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
    func setupToolBar() {
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.backgroundColor = .quaternarySystemFill
        messageTextView.layer.cornerRadius = 18
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageTextView.delegate = self
        messageTextView.text = "Message"
        messageTextView.textColor = .lightGray
        
        
        
        
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        
        stackViewForToolBar.axis = NSLayoutConstraint.Axis.horizontal
        stackViewForToolBar.distribution  = UIStackView.Distribution.equalSpacing
        stackViewForToolBar.alignment = UIStackView.Alignment.bottom
        stackViewForToolBar.spacing = 8
        stackViewForToolBar.addArrangedSubview(messageTextView)
        stackViewForToolBar.addArrangedSubview(button)
        
        let stackViewToolBarItem = UIBarButtonItem(customView: stackViewForToolBar)
        inputMessageToolBar.items = [stackViewToolBarItem]
        
        
        let size = CGSize(width: messageTextView.frame.size.width, height: .infinity)
        let estimatedSize = messageTextView.sizeThatFits(size)
        [
            button.widthAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 36),
            messageTextView.heightAnchor.constraint(equalToConstant: estimatedSize.height),
            messageTextView.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8),
            inputMessageToolBar.heightAnchor.constraint(equalToConstant: estimatedSize.height + 13)
        ].forEach({ $0.isActive = true })
        
        
    }
}
