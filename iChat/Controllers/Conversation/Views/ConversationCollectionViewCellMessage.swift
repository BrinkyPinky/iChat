//
//  ConversationCollectionViewCellMessage.swift
//  iChat
//
//  Created by Егор Шилов on 04.09.2022.
//

import UIKit

protocol ConversationCollectionViewCellMessageRepresentable {
    var messageCellModel: CellIdentifiable? { get set }
}

class ConversationCollectionViewCellMessage: UICollectionViewCell, ConversationCollectionViewCellMessageRepresentable {
    @IBOutlet var viewBackgroundTheMessage: UIView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var messageText: UILabel!
    @IBOutlet private var isReadLabel: UIImageView!
    
    var messageCellModel: CellIdentifiable? {
        didSet {
            setupMessage()
        }
    }
    
    private func setupMessage() {
        guard let cellModel = messageCellModel as? MessageCellViewModel else { return }
        messageText.text = cellModel.messageText
        timeLabel.text = cellModel.messageDate
        
        cellModel.selfSender ?? false ? outgoingMessage(cellModel: cellModel) : incomingMessage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
    
    private func incomingMessage() {
        viewBackgroundTheMessage.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        viewBackgroundTheMessage.layer.cornerRadius = 15
        
        isReadLabel.isHidden = true
        self.transform = CGAffineTransform(scaleX: -1, y: 1)
        timeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        viewBackgroundTheMessage.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        viewBackgroundTheMessage.backgroundColor = #colorLiteral(red: 0.9131569266, green: 0.9380695224, blue: 0.993408978, alpha: 1)
        messageText.textColor = .black
    }
    
    private func outgoingMessage(cellModel: MessageCellViewModel) {
        viewBackgroundTheMessage.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner
        ]
        viewBackgroundTheMessage.layer.cornerRadius = 15
        
        isReadLabel.isHidden = false
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        timeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        messageText.transform = CGAffineTransform(scaleX: 1, y: 1)
        viewBackgroundTheMessage.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        viewBackgroundTheMessage.backgroundColor = #colorLiteral(red: 0.3390406966, green: 0.478356421, blue: 0.9565412402, alpha: 1)
        messageText.textColor = .white
        
        isReadLabel.image = cellModel.isRead ?? false ?
        UIImage(systemName: "arrowshape.turn.up.left.2.fill") :
        UIImage(systemName: "arrowshape.turn.up.left.2")
    }
}
