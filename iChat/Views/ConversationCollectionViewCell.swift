//
//  ConversationCollectionViewCell.swift
//  iChat
//
//  Created by Егор Шилов on 04.09.2022.
//

import UIKit

class ConversationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var viewBackgroundTheMessage: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var messageText: UILabel!
    
    
    
    var text: String = "" {
        didSet {
            messageText.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
    
    override func layoutSubviews() {
        viewBackgroundTheMessage.clipsToBounds = true
        viewBackgroundTheMessage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        viewBackgroundTheMessage.layer.cornerRadius = 15
        
        incomingMessage()
    }
    
    func incomingMessage() {
        self.transform = CGAffineTransform(scaleX: -1, y: 1);
        timeLabel.transform = CGAffineTransform(scaleX: -1, y: 1);
        messageText.transform = CGAffineTransform(scaleX: -1, y: 1);

        viewBackgroundTheMessage.backgroundColor = .quaternarySystemFill
        messageText.textColor = .black
    }
}
