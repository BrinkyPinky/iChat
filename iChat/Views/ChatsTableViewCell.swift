//
//  ChatsTableViewCell.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import UIKit

protocol ChatsViewModelCellRepresentable {
    var chatsViewModelCell: CellIdentifiable? { get set }
}

class ChatsTableViewCell: UITableViewCell, ChatsViewModelCellRepresentable {
    @IBOutlet private var fullname: UILabel!
    @IBOutlet private var username: UILabel!
    @IBOutlet private var messageText: UILabel!
    @IBOutlet private var personImage: UIImageView!
    @IBOutlet var messageDate: UILabel!
    
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
