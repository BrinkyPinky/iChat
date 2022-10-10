//
//  ConversationCollectionHeaderView.swift
//  iChat
//
//  Created by Егор Шилов on 04.09.2022.
//

import UIKit

protocol MessageHeaderCellModelRepresentable {
    var messageHeaderCellModel: CellIdentifiable? { get set }
}

class ConversationCollectionHeaderView: UICollectionReusableView, MessageHeaderCellModelRepresentable {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var backgroundViewDateLabel: UIView!
    
    var messageHeaderCellModel: CellIdentifiable? {
        didSet {
            setupHeader()
        }
    }
    
    func setupHeader() {
        let headerCellViewModel = messageHeaderCellModel as! HeadersMessageCellViewModel
        dateLabel.text = headerCellViewModel.date
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
    }
    
    override func layoutSubviews() {    
        backgroundViewDateLabel.clipsToBounds = true
        backgroundViewDateLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        backgroundViewDateLabel.layer.cornerRadius = 15
        
        backgroundViewDateLabel.backgroundColor = #colorLiteral(red: 0.9131569266, green: 0.9380695224, blue: 0.993408978, alpha: 1)
    }
}
