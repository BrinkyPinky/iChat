//
//  ChatsTableInteractor.swift
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

protocol ChatsBusinessLogic {
    func getChats()
    func selectedRow(row: CellIdentifiable)
}

protocol ChatsDataStore {
    var userInfo: ConversationUserModel? { get set }
}

class ChatsInteractor: ChatsBusinessLogic, ChatsDataStore {
    
    var presenter: ChatsPresentationLogic?
    
    var userInfo: ConversationUserModel?
    
    var rawChats = [ChatModel]() {
        didSet {
            guard rawChats.isEmpty == false else { return }
            provideChats()
            RealmDataManager.shared.writeLastChats(chatModel: rawChats)
        }
    }

    // MARK: Get raw list of chats
    func getChats() {
        rawChats = RealmDataManager.shared.getLastChats()
        
        FireBaseDatabaseManager.shared.getChats { [unowned self] chat in
            guard rawChats.isEmpty == false else {
                rawChats.append(chat)
                return
            }
            rawChats = rawChats.map({
                if $0.email == chat.email {
                    return chat
                } else {
                    rawChats.append(chat)
                }
                return $0
            })
        }
    }
    
    func provideChats() {
        let response = Chats.gettingChats.Response(rawChats: rawChats)
        presenter?.presentChats(response: response)
    }
    
    func selectedRow(row: CellIdentifiable) {
        guard let rowViewModel = row as? ChatsViewModelCell else { return }
        userInfo = ConversationUserModel(
            fullName: rowViewModel.fullname,
            email: rowViewModel.email,
            username: rowViewModel.username,
            isOnline: rowViewModel.isOnline
        )
    }
}
