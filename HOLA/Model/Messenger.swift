//
//  Model.swift
//  HOLY
//
//  Created by Клим Бакулин on 11.12.2022.
//

import Foundation
import UIKit

enum AuthResponse {
    case success, noVerify, error
}

struct Slides {
    var id: Int
    var text: String
    var image: UIImage
}

struct LoginField {
    var email: String
    var password: String
}

struct ResponseCode {
    var code: Int
}


struct User {
    var id: String?
    var email: String?
    var name: String?
    var avatarURL: String?
    var avatarImage: UIImageView?
}

struct OtherInfoOfUser{
    var name: String?
    var avatar: UIImage?
}

struct ChatListItem {
    var chatID: String?
    var otherID: String?
}

struct Chat: Comparable {
    
    var lastMessage: String?
    var date: Date?
    var id: String?
    var otherID: String?
    var userID: String?
    var email: String?
    var name: String?
    var avatarURL: String?
    var avatarImage: UIImageView?
    
    static func < (lhs: Chat, rhs: Chat) -> Bool {
        if let lhsDate = lhs.date, let rhsDate = rhs.date {
            return lhsDate > rhsDate
        } else {
            return true
        }
    }
    
}
