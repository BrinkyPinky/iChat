//
//  ConversationModels.swift
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

typealias MessageCellViewModel = Conversation.Messages.ViewModel.MessageCellViewModel
typealias HeadersMessageCellViewModel = Conversation.Messages.ViewModel.HeadersMessageCellViewModel

enum Conversation {
    // MARK: Use cases
    
    enum fullnameLabel {
        struct Response {
            let fullname: String
        }
        
        struct ViewModel {
            let fullname: String
        }
    }
    
    enum Messages {
        struct Response {
            let rawMessages: [MessageModel]
        }
        
        struct ViewModel {
            struct MessageCellViewModel: CellIdentifiable {
                var cellIdentifier: String {
                    "MessageCell"
                }
                
                let messageText: String?
                let messageDate: String?
                let isRead: Bool?
                let selfSender: Bool?
                
                init(message: MessageModel) {
                    messageText = message.messageText
                    messageDate = message.date
                    isRead = message.isRead
                    selfSender = message.selfSender
                }
            }
            
            struct HeadersMessageCellViewModel: CellIdentifiable {
                var cellIdentifier: String {
                    "MessageHeader"
                }
                
                let date: String?
                
                init(date: String) {
                    self.date = date
                }
                
            }
            
            let messagesRows: [[CellIdentifiable]]
            
//            let messages: [[MessageModel]]
            let headersDatesRows: [CellIdentifiable]
        }
    }
    
    enum SendMessage {
        struct Request {
            let messageText: String
        }
    }
}
