//
//  ConversationCollectionViewCellOutgoingMessage.swift
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
        viewBackgroundTheMessage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        viewBackgroundTheMessage.layer.cornerRadius = 15
        
        switch cellModel.selfSender {
        case true:
            outgoingMessage(cellModel: cellModel)
        case false:
            incomingMessage()
        default:
            print("")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
    
    private func incomingMessage() {
        isReadLabel.isHidden = true
        self.transform = CGAffineTransform(scaleX: -1, y: 1)
        timeLabel.transform = CGAffineTransform(scaleX: -1, y: 1)
        messageText.transform = CGAffineTransform(scaleX: -1, y: 1)
        viewBackgroundTheMessage.backgroundColor = UIColor(
            red: 234/255,
            green: 239/255,
            blue: 252/255,
            alpha: 1
        )
        messageText.textColor = .black
    }
    
    private func outgoingMessage(cellModel: MessageCellViewModel) {
        isReadLabel.isHidden = false
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        timeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
        messageText.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        viewBackgroundTheMessage.backgroundColor = UIColor(
            red: 94/255,
            green: 121/255,
            blue: 236/255,
            alpha: 1
        )
        messageText.textColor = .white
        
        isReadLabel.image = cellModel.isRead ?? false ? UIImage(systemName: "arrowshape.turn.up.left.2.fill") : UIImage(systemName: "arrowshape.turn.up.left.2")
    }
}
