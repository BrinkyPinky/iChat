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
}

// MARK: Appearance of collection view
extension ConversationViewController {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MessageHeader",
                for: indexPath
            ) as! ConversationCollectionHeaderView
            
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        ) as! ConversationCollectionHeaderView
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = self.collectionView(collectionView, cellForItemAt: indexPath) as! ConversationCollectionViewCell
        
        return cell.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}