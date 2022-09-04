//
//  ConversationCollectionHeaderView.swift
//  iChat
//
//  Created by Егор Шилов on 04.09.2022.
//

import UIKit

class ConversationCollectionHeaderView: UICollectionReusableView {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var backgroundViewDateLabel: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
    
    override func layoutSubviews() {
        dateLabel.text = "Yesterday"
        
        backgroundViewDateLabel.clipsToBounds = true
        backgroundViewDateLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        backgroundViewDateLabel.layer.cornerRadius = 15
    }
}
