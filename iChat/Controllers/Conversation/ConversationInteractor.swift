//
//  ConversationInteractor.swift
//  iChat
//
//  Created by Егор Шилов on 05.09.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ConversationBusinessLogic {
    func sendMessage(request: Conversation.SendMessage.Request)
}

protocol ConversationDataStore {
    var userInfo: UserCellViewModel? { get set }
}

class ConversationInteractor: ConversationBusinessLogic, ConversationDataStore {
    
    // MARK: Getting Needed User Information from Another View by Routing
    
    var userInfo: UserCellViewModel? {
        didSet {
            let response = Conversation.fullnameLabel.Response(fullname: userInfo?.fullName ?? "Unkown")
            presenter?.presentUserFullname(response: response)
            
            getMessages(with: userInfo?.email ?? "")
        }
    }
    
    // MARK: Get Messages From Database
    
    private func getMessages(with email: String) {
        var rawMessages: [MessageModel] = [] {
            didSet {
                let response = Conversation.Messages.Response(rawMessages: rawMessages)
                presenter?.presentMessages(response: response)
            }
        }
        
        FireBaseDatabaseManager.shared.getMessages(withEmail: email, andLimit: 25) { arrayOfMessages in
            rawMessages = []
            rawMessages.append(contentsOf: arrayOfMessages)
        }
    }
    
    // MARK: Send Message to Database
    
    func sendMessage(request: Conversation.SendMessage.Request) {
        guard userInfo != nil else { return }
        FireBaseDatabaseManager.shared.sendMessage(to: userInfo!.email, message: request.messageText)
    }
    
    var presenter: ConversationPresentationLogic?
}
