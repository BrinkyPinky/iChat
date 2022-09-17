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
        
        if self.window?.traitCollection.userInterfaceStyle == .light {
            backgroundViewDateLabel.backgroundColor = UIColor(
                red: 234/255,
                green: 239/255,
                blue: 252/255,
                alpha: 1
            )
        } else {
            backgroundViewDateLabel.backgroundColor = #colorLiteral(red: 0.2763007581, green: 0.2438369989, blue: 0.3258192241, alpha: 1)
        }
    }
}
