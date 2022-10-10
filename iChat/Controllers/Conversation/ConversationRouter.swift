//
//  ConversationRouter.swift
//  iChat
//
//  Created by Егор Шилов on 20.09.2022.
//

import Foundation

protocol ConversationDataPassing {
    var dataStore: ConversationDataStore? { get }
}

class ConversationRouter: NSObject, ConversationDataPassing {
    weak var viewController: ConversationViewController?
    var dataStore: ConversationDataStore?
}
