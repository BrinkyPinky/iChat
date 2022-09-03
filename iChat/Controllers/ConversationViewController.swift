//
//  ConversationViewController.swift
//  iChat
//
//  Created by Егор Шилов on 03.09.2022.
//

import UIKit

class ConversationViewController: UIViewController {
    @IBOutlet var inputMessageToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        let messageTextView = UITextView()
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.font = UIFont.systemFont(ofSize: 16)
        messageTextView.backgroundColor = .quaternarySystemFill
        messageTextView.layer.cornerRadius = 18
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageTextView.delegate = self
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
       

        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.bottom
        stackView.spacing = 8

        stackView.addArrangedSubview(messageTextView)
        stackView.addArrangedSubview(button)
        
        let wok = UIBarButtonItem(customView: stackView)
                
        inputMessageToolBar.items = [wok]
        
        [
            button.widthAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 36),
            messageTextView.heightAnchor.constraint(equalToConstant: 36),
            messageTextView.widthAnchor.constraint(equalToConstant: 600)
        ].forEach({ $0.isActive = true })
    }
}


extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        var configurator = cell.defaultContentConfiguration()
        configurator.text = "row: \(indexPath.row)"
        cell.contentConfiguration = configurator
        
        return cell
    }
    
}

extension ConversationViewController: UITextViewDelegate {
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
        adjustContentSize(tv: textView)

    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
}
