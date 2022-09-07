//
//  ConversationCollectionViewCellOutgoingMessage.swift
//  iChat
//
//  Created by Егор Шилов on 04.09.2022.
//

import UIKit

protocol OutgoingMessageCellModelRepresentable {
    var messageCellModel: CellIdentifiable? { get set }
}

class ConversationCollectionViewCellOutgoingMessage: UICollectionViewCell, OutgoingMessageCellModelRepresentable {
    @IBOutlet var viewBackgroundTheMessage: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var messageText: UILabel!
    
    var messageCellModel: CellIdentifiable? {
        didSet {
            setupMessage()
        }
    }
        
    func setupMessage() {
        guard let cellModel = messageCellModel as? MessageCellViewModel else { return }
        messageText.text = cellModel.messageText
        timeLabel.text = cellModel.messageDate
        
        viewBackgroundTheMessage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        viewBackgroundTheMessage.layer.cornerRadius = 15
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
}
