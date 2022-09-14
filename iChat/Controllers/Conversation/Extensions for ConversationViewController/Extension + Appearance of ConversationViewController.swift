//
//  Extension + AppearanceConversationViewController.swift
//  iChat
//
//  Created by Егор Шилов on 05.09.2022.
//

import UIKit


// MARK: SetupUI
extension ConversationViewController {
    
    func setupUI() {
        self.hideKeyboardWhenTappedAround()
        
        // MARK: Actions
        
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonPressed), for: .touchUpInside)
        
        // MARK: Toolbar setup
        
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
        MessageToolBar.items = [stackViewToolBarItem]
        
        let size = CGSize(width: messageTextView.frame.size.width, height: .infinity)
        let estimatedSize = messageTextView.sizeThatFits(size)
        [
            sendMessageButton.widthAnchor.constraint(equalToConstant: 36),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 36),
            messageTextView.heightAnchor.constraint(equalToConstant: estimatedSize.height),
            messageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -8),
            MessageToolBar.heightAnchor.constraint(equalToConstant: estimatedSize.height + 13)
        ].forEach({ $0.isActive = true })
        
        // MARK: NavigationBar Setup
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = UIColor(
            red: 234/255,
            green: 239/255,
            blue: 252/255,
            alpha: 1
        )
        navigationBarAppearance.shadowColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        
        // MARK: CollectionView Setup
        
        conversationCollectionView.clipsToBounds = true
        conversationCollectionView.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        conversationCollectionView.layer.cornerRadius = 50
        
        // MARK: TabBarController Setup
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setTitle(title:String, isActive: Bool) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = isActive ? UIColor(red: 94/255, green: 121/255, blue: 236/255, alpha: 1) : .secondaryLabel
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        subtitleLabel.text = isActive ? "Online" : "Offline"
        subtitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)

        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }

        return titleView
    }
}

// MARK: Height of collection view
extension ConversationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let messageCellModel = messagesRows[indexPath.section][indexPath.row] as! MessageCellViewModel
                
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 243, height: 368))
        label.text = messageCellModel.messageText
        label.numberOfLines = 0
        label.sizeToFit()
        
        return CGSize(width: view.frame.width, height: label.frame.height + 59)
    }
}

