//
//  Extension + TextField.swift
//  iChat
//
//  Created by Егор Шилов on 27.08.2022.
//

import UIKit

extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.systemGray5.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        borderStyle = .none
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
