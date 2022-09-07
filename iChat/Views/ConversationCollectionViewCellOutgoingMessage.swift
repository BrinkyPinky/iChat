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
    
    var cellHeight: CGFloat = 0
    
    func setupMessage() {
        guard let cellModel = messageCellModel as? MessageCellViewModel else { return }
        messageText.text = cellModel.messageText
        timeLabel.text = cellModel.messageDate
        
        cellHeight = viewBackgroundTheMessage.bounds.height
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
    
    override func layoutSubviews() {
//            viewBackgroundTheMessage.clipsToBounds = true
            viewBackgroundTheMessage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
            viewBackgroundTheMessage.layer.cornerRadius = 15
    }
    
    func incomingMessage() {
        self.transform = CGAffineTransform(scaleX: -1, y: 1)
        messageText.transform = CGAffineTransform(scaleX: -1, y: 1)
        timeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        viewBackgroundTheMessage.backgroundColor = .quaternarySystemFill
        messageText.textColor = .black
    }
}
