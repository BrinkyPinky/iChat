//
//  Extension + AppearanceConversationViewController.swift
//  iChat
//
//  Created by Егор Шилов on 05.09.2022.
//

import UIKit


// MARK: SetupUI
extension ConversationViewController {
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI() {
        
        // MARK: Scroll Down Button
        
        scrollDownButton.isEnabled = false
        scrollDownButton.layer.opacity = 0
        
        // MARK: Tap Recognizer to dismiss keyboard
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        conversationCollectionView.addGestureRecognizer(tap)
        
        // MARK: View behind collectionView BackgroundColor
        
        view.backgroundColor = #colorLiteral(red: 0.9345796704, green: 0.9495114684, blue: 0.9921932817, alpha: 1)
        
        // MARK: Send Message Button Action
        
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
        navigationBarAppearance.backgroundColor = #colorLiteral(red: 0.9131569266, green: 0.9380695224, blue: 0.993408978, alpha: 1)
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
    
    // MARK: Height of the TextView depending on the text in
    
    func setTitle(title:String, isActive: Bool) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = isActive ? #colorLiteral(red: 0.3390406966, green: 0.478356421, blue: 0.9565412402, alpha: 1) : .secondaryLabel
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        subtitleLabel.text = isActive ? "Online" : "Offline"
        subtitleLabel.sizeToFit()

        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: max(titleLabel.frame.size.width,
                           subtitleLabel.frame.size.width),
                height: 30
            )
        )
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
    
    // MARK: ConversationCollectionView scrolling
    
    func reloadConversationCollectionView(viewModel: Conversation.Messages.ViewModel, with completion: @escaping () -> Void) {
        DispatchQueue.main.async { [self] in
            let isItFirstDisplayingMessages = headersDatesRows.isEmpty
            let currentContentSize = conversationCollectionView.contentSize.height
            let currentOffset = conversationCollectionView.contentOffset.y
            
            completion()
                        
            conversationCollectionView.reloadData()
            conversationCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            conversationCollectionView.layoutIfNeeded()
            
            let heightOfContentSize = self.conversationCollectionView.contentSize.height
            let heightOfCollectionView = self.conversationCollectionView.frame.height
            
            let lastSection = conversationCollectionView.numberOfSections - 1
            let lastRow = conversationCollectionView.numberOfItems(inSection: lastSection) - 1
            
            if heightOfContentSize <= heightOfCollectionView + 50 {

            } else if isItFirstDisplayingMessages {
                conversationCollectionView.scrollToItem(
                    at: IndexPath(row: lastRow, section: lastSection),
                    at: .bottom,
                    animated: false
                )
            } else if currentOffset <= 50 {
                let targetYPosition = heightOfContentSize - currentContentSize
                conversationCollectionView.contentOffset.y = targetYPosition
            } else {
                let targetYPosition = heightOfContentSize - heightOfCollectionView
                guard currentOffset >= targetYPosition - 300 else { return }
                conversationCollectionView.scrollToItem(
                    at: IndexPath(row: lastRow, section: lastSection),
                    at: .bottom,
                    animated: true
                )
            }
        }
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

