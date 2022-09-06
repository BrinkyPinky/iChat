//
//  UserTableViewCell.swift
//  iChat
//
//  Created by Егор Шилов on 02.09.2022.
//

import UIKit

protocol UserCellModelRepresentable {
    var userCellModel: CellIdentifiable? { get set }
}

class UserTableViewCell: UITableViewCell, UserCellModelRepresentable {
    var userCellModel: CellIdentifiable? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        guard let cellModel = userCellModel as? UserCellViewModel else { return }
        
        var content = defaultContentConfiguration()
        content.text = cellModel.username
        content.secondaryText = cellModel.fullName
        contentConfiguration = content
    }
}
