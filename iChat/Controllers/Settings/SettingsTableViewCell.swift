//
//  SettingsTableViewCell.swift
//  iChat
//
//  Created by Егор Шилов on 08.09.2022.
//

import UIKit

protocol SettingsTableViewCellRepresentable {
    var cellViewModel: CellIdentifiable? { get set }
}

class SettingsTableViewCell: UITableViewCell, SettingsTableViewCellRepresentable {
       
    var cellViewModel: CellIdentifiable? {
        didSet {
            setup()
        }
    }
    
    func setup() {
        let cellViewModel = cellViewModel as! SettingCellViewModel
        
        switch cellViewModel.type {
        case .logout:
            var configuration = defaultContentConfiguration()
            configuration.text = cellViewModel.text
            configuration.textProperties.color = .red
            configuration.textProperties.alignment = .center
            contentConfiguration = configuration
        case .simple:
            var configuration = defaultContentConfiguration()
            configuration.text = cellViewModel.text
            configuration.image = UIImage(systemName: cellViewModel.imagename!)
            contentConfiguration = configuration
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
