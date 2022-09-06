//
//  ConversationPresenterWorkerMessagesSorting.swift
//  iChat
//
//  Created by Егор Шилов on 06.09.2022.
//

import Foundation

import UIKit

class ConversationPresenterWorkerMessagesSorting {
    func sortMessages(rawMessages: [MessageModel]) -> ([[MessageCellViewModel]], [String]) {
        //        var referenceDateToCompare: String?
        //
        //        var headersDate = [String]()
        //
        //        var sortedMessages = [[MessageCell]]()
        //        var firstLevelMessages = [MessageModel]()
        //
        //        rawMessages.forEach { messageModel in
        //            let timeInterval = TimeInterval(messageModel.date)
        //            var convertedDateValue = Date(timeIntervalSinceReferenceDate: timeInterval ?? 0)
        //            let secondsFromGMT = TimeZone.current.secondsFromGMT()
        //            convertedDateValue.addTimeInterval(TimeInterval(secondsFromGMT))
        //
        //            let dayOfDate = convertedDateValue.formatted(date: .numeric, time: .omitted)
        //
        //
        //            if referenceDateToCompare == nil {
        //                referenceDateToCompare = dayOfDate
        //                headersDate.append(convertedDateValue.formatted(date: .complete, time: .omitted))
        //            }
        //
        //            if dayOfDate == referenceDateToCompare {
        //                firstLevelMessages.append(
        //                    MessageModel(
        //                        messageText: messageModel.messageText,
        //                        date: convertedDateValue.formatted(date: .omitted, time: .shortened),
        //                        isRead: messageModel.isRead,
        //                        selfSender: messageModel.selfSender
        //                    )
        //                )
        //            } else {
        //                sortedMessages.append(firstLevelMessages)
        //                firstLevelMessages = []
        //                referenceDateToCompare = dayOfDate
        //                headersDate.append(convertedDateValue.formatted(date: .complete, time: .omitted))
        //
        //                firstLevelMessages.append(
        //                    MessageModel(
        //                        messageText: messageModel.messageText,
        //                        date: convertedDateValue.formatted(date: .omitted, time: .shortened),
        //                        isRead: messageModel.isRead,
        //                        selfSender: messageModel.selfSender
        //                    )
        //                )
        //            }
        //        }
        //
        //        sortedMessages.append(firstLevelMessages)
        //
        //        return (sortedMessages, headersDate)
        
        var referenceDateToCompare: String?
        
        var headersDate = [String]()
        
        var sortedMessages = [[MessageCellViewModel]]()
        var firstLevelMessages = [MessageCellViewModel]()
        
        rawMessages.forEach { messageModel in
            let timeInterval = TimeInterval(messageModel.date)
            var convertedDateValue = Date(timeIntervalSinceReferenceDate: timeInterval ?? 0)
            let secondsFromGMT = TimeZone.current.secondsFromGMT()
            convertedDateValue.addTimeInterval(TimeInterval(secondsFromGMT))
            
            let dayOfDate = convertedDateValue.formatted(date: .numeric, time: .omitted)
            
            
            if referenceDateToCompare == nil {
                referenceDateToCompare = dayOfDate
                headersDate.append(convertedDateValue.formatted(date: .complete, time: .omitted))
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
                headersDate.append(convertedDateValue.formatted(date: .complete, time: .omitted))
                
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
        
        return (sortedMessages, headersDate)
    }
}
