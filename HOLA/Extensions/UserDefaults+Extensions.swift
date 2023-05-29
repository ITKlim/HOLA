//
//  UserDefaults+Extension.swift
//  HOLY
//
//  Created by Клим Бакулин on 22.01.2023.
//

import Foundation


extension UserDefaults {
    
    var isLogin: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isLogin")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isLogin")
        }
    }
    
}
