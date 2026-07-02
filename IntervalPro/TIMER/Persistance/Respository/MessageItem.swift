//
//  MessageItem.swift
//  TIMER
//
//  Created by Aditya Maroo on 09/09/24.
//

import Foundation
import CoreData
import SwiftUI


class MessageItem {
    static let shared = MessageItem()
    
  
    func addMessageItems(delay: String, messageName: String)->MessageItems{
        let messageItem = MessageItems(context: CoreDataManager.shared.context)
        messageItem.messageName = messageName
        messageItem.delay = delay
        return messageItem
    }
    func editMessageData(messageData: MessageItems, name: String?, delay: String?){
        messageData.messageName = name ?? messageData.messageName
        messageData.delay = delay ?? messageData.delay
        CoreDataManager.shared.saveContext()
    }
}
