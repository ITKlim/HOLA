//
//  Message.swift
//  HOLA
//
//  Created by Клим Бакулин on 23.05.2023.
//

import Foundation
import MessageKit

public struct Sender: SenderType {
    
    public var senderId: String
    public var displayName: String
    var avatar: Avatar?
    
}

public struct Message: MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
}
