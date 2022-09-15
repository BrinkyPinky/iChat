//
//  ChatsTableViewCell.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import UIKit
import SwiftUI

protocol ChatsViewModelCellRepresentable {
    var chatsViewModelCell: CellIdentifiable? { get set }
}

class ChatsTableViewCell: UITableViewCell, ChatsViewModelCellRepresentable {
    @IBOutlet private var fullname: UILabel!
    @IBOutlet private var username: UILabel!
    @IBOutlet private var messageText: UILabel!
    @IBOutlet private var personImage: UIImageView!
    @IBOutlet var messageDate: UILabel!
    @IBOutlet var viewBackgroundMessagesCount: UIView!
    @IBOutlet var messagesCountLabel: UILabel!
    
    @IBOutlet var onlineStatusView: UIView!
    @IBOutlet var backgroundOnlineStatusView: UIView!
    
    var chatsViewModelCell: CellIdentifiable? {
        didSet {
            setup()
        }
    }
    
    func setup() {
        let chatsViewModelCell = chatsViewModelCell as? ChatsViewModelCell
        
        fullname.text = chatsViewModelCell?.fullname
        username.text = chatsViewModelCell?.username
        messageText.text = chatsViewModelCell?.lastMessageText
        messageDate.text = chatsViewModelCell?.lastMessageDate
        personImage.layer.cornerRadius = personImage.frame.width / 2
        viewBackgroundMessagesCount.layer.cornerRadius = viewBackgroundMessagesCount.frame.width / 2
        onlineStatusView.layer.cornerRadius = onlineStatusView.frame.width / 2
        backgroundOnlineStatusView.layer.cornerRadius = backgroundOnlineStatusView.frame.width / 2
        
        if chatsViewModelCell?.isOnline == true {
            onlineStatusView.backgroundColor = .systemGreen
        } else {
            onlineStatusView.backgroundColor = .opaqueSeparator
        }
        
        if chatsViewModelCell?.unreadedMessagesCount != 0 {
            viewBackgroundMessagesCount.isHidden = false
            messagesCountLabel.isHidden = false
            messagesCountLabel.text = "\(chatsViewModelCell?.unreadedMessagesCount ?? 0)"
        } else {
            viewBackgroundMessagesCount.isHidden = true
            messagesCountLabel.isHidden = true
        }
        
        var email = chatsViewModelCell?.email ?? ""
        email = email.replacingOccurrences(of: "-", with: "@")
        email = email.replacingOccurrences(of: "-", with: ".")
        
        if let imageData = RealmDataManager.shared.getUserImage(email: email) {
            personImage.image = UIImage(data: imageData)
        }
        
        FireBaseStorageManager.shared.getUserImage(emailIfOtherUser: chatsViewModelCell?.email) { [unowned self] imageData in
                guard let imageData = imageData else { return }
                personImage.image = UIImage(data: imageData)
            RealmDataManager.shared.saveUserImage(imageData: imageData, email: chatsViewModelCell?.email ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
