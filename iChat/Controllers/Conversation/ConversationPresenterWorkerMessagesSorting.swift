//
//  ConversationPresenterWorkerMessagesSorting.swift
//  iChat
//
//  Created by Егор Шилов on 06.09.2022.
//

import Foundation

import UIKit

class ConversationPresenterWorkerMessagesSorting {
    func sortMessages(rawMessages: [MessageModel]) -> ([[MessageCellViewModel]], [HeadersMessageCellViewModel]) {
        
        var referenceDateToCompare: String?
        
        var headersDatesRows = [HeadersMessageCellViewModel]()
        
        var sortedMessages = [[MessageCellViewModel]]()
        var firstLevelMessages = [MessageCellViewModel]()
        
        rawMessages.forEach { messageModel in
            let timeInterval = TimeInterval(messageModel.date)
            let convertedDateValue = Date(timeIntervalSince1970: timeInterval ?? 0)
            
            let dayOfDate = convertedDateValue.formatted(date: .numeric, time: .omitted)
            
            if referenceDateToCompare == nil {
                referenceDateToCompare = dayOfDate
                headersDatesRows.append(HeadersMessageCellViewModel(
                    date: convertedDateValue.formatted(date: .complete, time: .omitted)
                ))
            }
            
            if dayOfDate == referenceDateToCompare {
                firstLevelMessages.append(
                    MessageCellViewModel(
                        message:
                            MessageModel(
                                messageText: messageModel.messageText,
                                date: convertedDateValue.formatted(date: .omitted, time: .shortened),
                                isRead: messageModel.isRead,
                                selfSender: messageModel.selfSender
                            )
                    )
                )
            } else {
                sortedMessages.append(firstLevelMessages)
                firstLevelMessages = []
                referenceDateToCompare = dayOfDate
                headersDatesRows.append(HeadersMessageCellViewModel(
                    date: convertedDateValue.formatted(date: .complete, time: .omitted)
                ))
                
                firstLevelMessages.append(
                    MessageCellViewModel(
                        message:
                            MessageModel(
                                messageText: messageModel.messageText,
                                date: convertedDateValue.formatted(date: .omitted, time: .shortened),
                                isRead: messageModel.isRead,
                                selfSender: messageModel.selfSender
                            )
                    )
                )
            }
        }
        
        sortedMessages.append(firstLevelMessages)
        
        return (sortedMessages, headersDatesRows)
    }
}
