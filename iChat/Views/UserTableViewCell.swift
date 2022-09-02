//
//  UserTableViewCell.swift
//  iChat
//
//  Created by Егор Шилов on 02.09.2022.
//

import UIKit

protocol CellModelRepresentable {
    var cellModel: CellIdentifiable? { get set }
}

class UserTableViewCell: UITableViewCell, CellModelRepresentable {
    var cellModel: CellIdentifiable? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        guard let cellModel = cellModel as? UserCellViewModel else { return }
        
        var content = defaultContentConfiguration()
        content.text = cellModel.username
        content.secondaryText = cellModel.fullName
        contentConfiguration = content
    }
}
