//
//  ChatsTablePresenter.swift
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

protocol ChatsPresentationLogic {
    func presentChats(response: Chats.gettingChats.Response)
}

class ChatsPresenter: ChatsPresentationLogic {
    
    weak var viewController: ChatsDisplayLogic?
    
    // MARK: Do something
    
    func presentChats(response: Chats.gettingChats.Response) {
        var chatsViewModelCell = [ChatsViewModelCell]()
        
        response.rawChats.forEach { chatModel in
            let rawDate = Date(timeIntervalSince1970: Double(chatModel.lastMessageDate!)!)
            let convertedDate = rawDate.formatted(date: .omitted, time: .shortened)
            
            chatsViewModelCell.append(
                ChatsViewModelCell(
                    chatModel: ChatModel(
                        email: chatModel.email,
                        fullname: chatModel.fullname,
                        lastMessageDate: convertedDate,
                        lastMessageText: chatModel.lastMessageText,
                        username: chatModel.username,
                        unreadedMessagesCount: chatModel.unreadedMessagesCount,
                        isOnline: chatModel.isOnline
                    )
                )
            )
        }
        
        let viewModel = Chats.gettingChats.ViewModel(rows: chatsViewModelCell)
        viewController?.displayChats(viewModel: viewModel)
    }
}
