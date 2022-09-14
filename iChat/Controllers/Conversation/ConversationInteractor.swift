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
    func getMessages(isNeedToUpLimit: Bool)
    func readMessage(request: Conversation.ReadMessage.Request)
    func deleteMessageForYourself(cellViewModel: CellIdentifiable)
    func deleteMessageForAll(cellViewModel: CellIdentifiable)
    func copyMessageToClipboard(cellViewModel: CellIdentifiable)
    func stopObservingMessages()
}

protocol ConversationDataStore {
    var userInfo: ConversationUserModel? { get set }
}

class ConversationInteractor: ConversationBusinessLogic, ConversationDataStore {
    
    private var limitOfMessages = 25 // limit on the number of messages we need
    
    // MARK: Getting Needed User Information from Another View by Routing
    
    var userInfo: ConversationUserModel? {
        didSet {
            FireBaseDatabaseManager.shared.checkUserStatus(otherEmail: userInfo?.email ?? "") { [unowned self] isOnline in
                let response = Conversation.userTitleLabel.Response(fullname: userInfo?.fullName ?? "Unknown", isOnline: isOnline)
                presenter?.presentTitle(response: response)
            }
            
            let response = Conversation.userTitleLabel.Response(fullname: userInfo?.fullName ?? "Unknown", isOnline: userInfo?.isOnline ?? false)
            presenter?.presentTitle(response: response)
            
            getMessages(isNeedToUpLimit: false)
        }
    }
    
    // MARK: Messages interaction
    
    func getMessages(isNeedToUpLimit: Bool) {
        guard FireBaseDatabaseManager.shared.isPaginating == false else { return }
            if isNeedToUpLimit == true {
                limitOfMessages += 25 // Its needed when user scrolls to top of collection view
            }
        
        var rawMessages: [MessageModel] = [] {
            didSet {
                guard rawMessages.isEmpty == false else { return }
                let response = Conversation.Messages.Response(rawMessages: rawMessages)
                presenter?.presentMessages(response: response)
            }
        }
                
        FireBaseDatabaseManager.shared.getMessages(withEmail: userInfo?.email ?? "", andLimit: limitOfMessages) { arrayOfMessages in
            rawMessages = []
            rawMessages.append(contentsOf: arrayOfMessages)
        }
    }
    
    func sendMessage(request: Conversation.SendMessage.Request) {
        guard userInfo != nil else { return }
        guard request.messageText != "" && request.messageText != "Message" else { return }
        FireBaseDatabaseManager.shared.removeConversationObservers(with: userInfo?.email ?? "", withOnlineStatus: false)
        FireBaseDatabaseManager.shared.sendMessage(to: userInfo!.email, withName: userInfo!.fullName, andUsername: userInfo!.username, message: request.messageText)
        getMessages(isNeedToUpLimit: false)
    }
    
    func readMessage(request: Conversation.ReadMessage.Request) {
        guard request.displayingCell.cellIdentifier == "IncomingMessage" else { return }
        guard let message = request.displayingCell as? MessageCellViewModel else { return }
        guard message.isRead == false else { return }
        FireBaseDatabaseManager.shared.readMessage(messageID: message.messageID, otherEmail: userInfo?.email ?? "")
    }
        
    // MARK: Context Menu Actions
    
    func deleteMessageForAll(cellViewModel: CellIdentifiable) {
        guard let cellViewModel = cellViewModel as? MessageCellViewModel else { return }
        
        FireBaseDatabaseManager.shared.deleteMessageForAll(messageID: cellViewModel.messageID, otherEmail: userInfo?.email ?? "")
    }
    
    func deleteMessageForYourself(cellViewModel: CellIdentifiable) {
        guard let cellViewModel = cellViewModel as? MessageCellViewModel else { return }

        FireBaseDatabaseManager.shared.deleteMessageForYourself(messageID: cellViewModel.messageID, otherEmail: userInfo?.email ?? "")
    }
    
    func copyMessageToClipboard(cellViewModel: CellIdentifiable) {
        guard let cellViewModel = cellViewModel as? MessageCellViewModel else { return }

        UIPasteboard.general.string = cellViewModel.messageText
    }
    
    // MARK: When view disappear database stops the observer for messages
    
    func stopObservingMessages() {
        FireBaseDatabaseManager.shared.removeConversationObservers(with: userInfo?.email ?? "", withOnlineStatus: true)
    }
    
    var presenter: ConversationPresentationLogic?
}
